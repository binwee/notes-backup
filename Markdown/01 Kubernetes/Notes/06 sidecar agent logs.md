```
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-test
spec:
  containers:
  - name: main-container
    image: [your-main-image]
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  - name: sidecar
    image: busybox
    imagePullPolicy: IfNotPresent
    args: ["/bin/sh", "-c", "tail -n+1 -f /var/log/xxx.log"]
    volumeMounts:
    - name: varlog
      mountPath: /var/log
  volumes:
  - name: varlog
    emptyDir: {}
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sidecar-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sidecar-test
  template:
    metadata:
      labels:
        app: sidecar-test
    spec:
      containers:
      - name: main-container
        image: [your-main-image]
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      - name: sidecar
        image: busybox
        imagePullPolicy: IfNotPresent
        args: ["/bin/sh", "-c", "tail -n+1 -f /var/log/xxx.log"]
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        emptyDir: {}
```


