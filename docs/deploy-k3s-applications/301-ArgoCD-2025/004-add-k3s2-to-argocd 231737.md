# Add k3s2 to master ArgoCD

https://devopscube.com/configure-multiple-kubernetes-clusters-argo-cd/

## Step 1

Create a service account in k3s2

This will create a serviceaccount, a clusterrole with full  cluster privileges, and bind the clusterrole to the serviceaccount.

We are giving full cluster privileges because Argo CD needs full  privileges on the cluster to create, delete, and manage applications on  any namespace with the required resources.

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argocd-manager-role
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-manager-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argocd-manager-role
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: kube-system
```

## Step 2 

In k3s2 create a secret

```
apiVersion: v1
kind: Secret
metadata:
  name: argocd-manager-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: argocd-manager
type: kubernetes.io/service-account-token
```

## Step 3

export the CA and Token to environmnet

```
ca=$(kubectl get -n kube-system secret/argocd-manager-token -o jsonpath='{.data.ca\.crt}')

token=$(kubectl get -n kube-system secret/argocd-manager-token -o jsonpath='{.data.token}' | base64 --decode)
```



## Step 4



In k3s1 ( where ArgoCD is installed)



```

cat <<EOF | kubectl apply -n argocd -f -
apiVersion: v1
kind: Secret
metadata:
  name: k3s2-secret
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: k3s2
  server: https://k3s2.k8s.lab
  config: |
    {
      "bearerToken": "${token}",
      "tlsClientConfig": {
        "serverName": "k3s2.k8s.lab",
        "caData": "${ca}"
      }
    }
EOF
```



