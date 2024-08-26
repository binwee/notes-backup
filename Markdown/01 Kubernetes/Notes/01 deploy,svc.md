
## deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: default
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      # nodeName: master01
      # nodeSelector:
      #   key: value
      containers:
      - name: nginx
        image: nginx:latest
        imagePullPolicy: IfNotPresent
        # imagePullPolicy: Never
        # imagePullPolicy: Always
        ports:
        - name: http80
          containerPort: 80
          protocol: TCP
        #resources:
          #limits:
            #cpu: 500m
            #memory: 500Mi
          #requests:
            #cpu: 500m
            #memory: 500Mi
        #volumeMounts:
        #- mountPath: "/data"
        #  name: pvc
      #tolerations:
      #- operator: "Exists"
      #volumes:
      #- name: pvc
      #  persistentVolumeClaim:
      #    claimName: nginx-pvc
```

## service
```
kubectl expose deployment [deploy-name] -n [ns-name] --type=NodePort --port=80 --target-port=80 --name=[svc-name]
```

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx-service
spec:
  type: NodePort
  # type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    # nodePort: 31710
```

