
## ServiceAccount

```
kubectl create sa [name] -n [namesapce]
```

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: serviceaccount-name
  namespace: namespace
```

## ClusterRole

```
kubectl create clusterrole [name] --verb create --resource deployment,statefulset,daemonset
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: clusterrole-name
rules:
- apiGroups:
  - ""
  resources:
  - deployments
  - statefulsets
  - daemonsets
  verbs:
  - create
```

## Role

```
kubectl create role [name] -n [namespace] --verb create --resource deployment,statefulset,daemonset
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: role-name
  namespace: namespace
rules:
- apiGroups:
  - ""
  resources:
  - deployments
  - statefulsets
  - daemonsets
  verbs:
  - create

```

## ClusterRoleBinding

```
kubectl create clusterrolebinding [name] --serviceaccount [namespace]:[serviceaccount] --clusterrole [clusterrole]
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: clusterrolebing-name
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: clusterrole-name
subjects:
- kind: ServiceAccount
  name: serviceaccount-name
  namespace: rbac-test

```

## Rolebinding

```
kubectl create rolebinding [name] -n [namespace] --serviceaccount [namespace]:[serviceaccount] --role [role]
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rolebinding-name
  namespace: namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: role-name
subjects:
- kind: ServiceAccount
  name: serviceaccount-name
  namespace: serviceaccount-namespace
```

