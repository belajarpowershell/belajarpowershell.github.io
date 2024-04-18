#### Deploy Longhorn

The worker nodes must have `iscsi` and `nfs` running. 

#### Check following services are installed on all Worker nodes

The following can be run on `alpine1` to check if the nodes meet the minimum requirements

```curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.6.1/scripts/environment_check.sh | bashshell
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.6.1/scripts/environment_check.sh | bash
```

If required can be installed as follows.

Only required to be deployed once. Can be deleted after deployment.

####  iscsi 

```
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.1/deploy/prerequisite/longhorn-iscsi-installation.yaml
```

#### nfs

```
# autoinstall using script
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.5/deploy/prerequisite/longhorn-nfs-installation.yaml
```



#### Minimum storage requirement

If you start with a low storage such as 5 GB , you might have challenges

Create the mount points on the worker nodes and mount it for use.

the volume mount name must be same across Worker the nodes. The is a minimum size for storage 



### Longhorn Deployment steps

#### Download Local helm charts. 

```
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm pull   longhorn/longhorn --version 1.5.3
mkdir longhorn-1.5.3 && tar -xvf longhorn-1.5.3.tgz --strip-components=1 -C \longhorn-1.5.3
```

Once the helm charts are extracted, set the `defaultDataPath` to `/longhorn_data`

````
<Values.yaml>
defaultSettings:
  defaultDataPath: /var/lib/longhorn-example/  
# change to the mount point on the workernode to /longhorn_data .
  
````

#### Use `app-of-apps` to deploy Longhorn

Create the file below and push this to the Repository. ArgoCD will then get the deployment details and create a new tab on the ArgoCD Portal.

```
cat <<EOF > app-of-apps/templates/longhorn-app-of-apps.yaml 

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: longhorn
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: clusters/ctx-k3s-cluster-77/longhorn-1.5.3
    targetRevision: HEAD
    helm:
      valueFiles:
      - values.yaml
      releaseName: longhorn
      parameters:
      - name: app
        value: longhorn
  destination:
    server: https://kubernetes.default.svc
    namespace: longhorn-system
  syncPolicy:
    #automated:
      #prune: true
      #selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF


```



Push the changes to the repository, here are the steps. Details are left out, so you have to add the correct file to be pushed.

```

# git status
# git add 
# git commit -m " Longhorn app-of-apps"
# git push

```

Once completed , ArgoCD will create a new tab for Longhorn, you can then sync using ArgoCD for this to be deployed to the cluster.



### DNS resolution

The Longhorn deployment has ingress configured, to ensure the FQDN `longhorn.k8s.labs` is resolvable ensure the DNS is updated. For this lab , the following must be updated.



```
In values file update to enable ingress and provide nginx class name >> "nginx"

#on alpine1
vi /etc/bind/master/k8s.lab
argocd          IN      A       192.168.100.208
longhorn          IN      A       192.168.100.208

#Restart bind named service
rc-service named restart 
```

You should now be able to access `longhorn.k8s.lab`



#### 