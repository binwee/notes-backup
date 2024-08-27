
## 关键术语

- 生产者和消费者（producer和consumer）：消息的发送者叫 Producer，消息的使用者和接受者是 Consumer，生产者将数据保存到 Kafka 集群中，消费者从中获取消息进行业务的处理。
- broker：Kafka 集群中有很多台 Server，其中每一台 Server 都可以存储消息，将每一台 Server 称为一个 kafka 实例，也叫做 broker。
- 主题（topic）：一个 topic 里保存的是同一类消息，相当于对消息的分类，每个 producer 将消息发送到 kafka 中，都需要指明要存的 topic 是哪个，也就是指明这个消息属于哪一类。
- 分区（partition）：每个 topic 都可以分成多个 partition，每个 partition 在存储层面是 append log 文件。任何发布到此 partition 的消息都会被直接追加到 log 文件的尾部。为什么要进行分区呢？最根本的原因就是：kafka基于文件进行存储，当文件内容大到一定程度时，很容易达到单个磁盘的上限，因此，采用分区的办法，一个分区对应一个文件，这样就可以将数据分别存储到不同的server上去，另外这样做也可以负载均衡，容纳更多的消费者。
- 偏移量（Offset）：一个分区对应一个磁盘上的文件，而消息在文件中的位置就称为 offset（偏移量），offset 为一个 long 型数字，它可以唯一标记一条消息。由于kafka 并没有提供其他额外的索引机制来存储 offset，文件只能顺序的读写，所以在kafka中几乎不允许对消息进行“随机读写”。

## 基本原理

1、分布式和分区（distributed、partitioned）

  我们说 kafka 是一个分布式消息系统，所谓的分布式，实际上我们已经大致了解。消息保存在 Topic 中，而为了能够实现大数据的存储，一个 topic 划分为多个分区，每个分区对应一个文件，可以分别存储到不同的机器上，以实现分布式的集群存储。另外，每个 partition 可以有一定的副本，备份到多台机器上，以提高可用性。

2、副本（replicated ）

  kafka 还可以配置 partitions 需要备份的个数(replicas),每个 partition 将会被备份到多台机器上,以提高可用性，备份的数量可以通过配置文件指定。

  这种冗余备份的方式在分布式系统中是很常见的，那么既然有副本，就涉及到对同一个文件的多个备份如何进行管理和调度。kafka 采取的方案是：每个 partition 选举一个 server 作为“leader”，由 leader 负责所有对该分区的读写，其他 server 作为 follower 只需要简单的与 leader 同步，保持跟进即可。如果原来的 leader 失效，会重新选举由其他的 follower 来成为新的 leader。

  至于如何选取 leader，实际上如果我们了解 ZooKeeper，就会发现其实这正是 Zookeeper 所擅长的，Kafka 使用 ZK 在 Broker 中选出一个 Controller，用于 Partition 分配和 Leader 选举。

  另外，这里我们可以看到，实际上作为 leader 的 server 承担了该分区所有的读写请求，因此其压力是比较大的，从整体考虑，有多少个 partition 就意味着会有多少个leader，kafka 会将 leader 分散到不同的 broker 上，确保整体的负载均衡。

3、整体数据流程

（1）数据生产过程（Produce）：

  对于生产者要写入的一条记录，可以指定四个参数：分别是 topic、partition、key 和 value，其中 topic 和 value（要写入的数据）是必须要指定的，而 key 和 partition 是可选的。

  对于一条记录，先对其进行序列化，然后按照 Topic 和 Partition，放进对应的发送队列中。如果 Partition 没填，那么情况会是这样的：a、Key 有填。按照 Key 进行哈希，相同 Key 去一个 Partition。b、Key 没填。Round-Robin 来选 Partition。

  producer 将会和Topic下所有 partition leader 保持 socket 连接，消息由 producer 直接通过 socket 发送到 broker。其中 partition leader 的位置( host : port )注册在 zookeeper 中，producer 作为 zookeeper client，已经注册了 watch 用来监听 partition leader 的变更事件，因此，可以准确的知道谁是当前的 leader。

  producer 端采用异步发送：将多条消息暂且在客户端 buffer 起来，并将他们批量的发送到 broker，小数据 IO 太多，会拖慢整体的网络延迟，批量延迟发送事实上提升了网络效率。

（2）数据消费过程（Consume）：

  对于消费者，不是以单独的形式存在的，每一个消费者属于一个 consumer group，一个 group 包含多个 consumer。特别需要注意的是：订阅 Topic 是以一个消费组来订阅的，发送到 Topic 的消息，只会被订阅此 Topic 的每个 group 中的一个 consumer 消费。

  如果所有的 Consumer 都具有相同的 group，那么就像是一个点对点的消息系统；如果每个 consumer 都具有不同的 group，那么消息会广播给所有的消费者。

  具体说来，这实际上是根据 partition 来分的，一个 Partition，只能被消费组里的一个消费者消费，但是可以同时被多个消费组消费，消费组里的每个消费者是关联到一个 partition 的，因此有这样的说法：对于一个 topic,同一个 group 中不能有多于 partitions 个数的 consumer 同时消费,否则将意味着某些 consumer 将无法得到消息。

  同一个消费组的两个消费者不会同时消费一个 partition。