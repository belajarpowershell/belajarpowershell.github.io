#### Longhorn node requirement configuration



#### Addtional tools required



```
apk add jq
```

https://longhorn.io/docs/1.5.3/deploy/install/#root-and-privileged-permission



Check if  worker nodes have the required applications

```
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.5.3/scripts/environment_check.sh | bash

```





Only required to be deployed once. Can delete after deployment.

install iscsi 

```

kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.3/deploy/prerequisite/longhorn-iscsi-installation.yaml
```

install nfs

```
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.3/deploy/prerequisite/longhorn-nfs-installation.yaml
```



