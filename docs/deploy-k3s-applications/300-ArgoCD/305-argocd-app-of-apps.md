## ArgoCD App of Apps

One of the benefits of using ArgoCD is the ability to deploy multiple applications. We use ArgoCD App of Apps configuration to deploy the individual applications. 

This concept might not makes sense if this is the first time you hear this, but its basically using code to add new applications.

Lets get this done.

#### Step 1 create root app ` app-of-apps-platform`

```
From k3s-repository/ on alpine1

mkdir -p argocd/templates
touch argocd/values.yaml

```

Create `Chart.yaml`

```

cat <<EOF > k3s-repository/argocd/Chart.yaml

apiVersion: v2
name: app-of-apps-platform
version: 1.0.0
EOF
```

Create the yaml to deploy the code to all new applications.

This code basically points the ArgoCD to the repository with the details of the new applications. Once a new application is loaded , ArgoCD will list the relevant services to be deployed.  It will make sense as you try this out on your own.

```
# This is to create the app of apps to be added to Argocd.

cat <<EOF > argocd/templates/app-of-apps-platform.yaml

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps-platform
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: argocd
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: app-of-app
  syncPolicy:
    #automated:
     #selfHeal: true
    syncOptions:
    - CreateNamespace=true  
EOF

```



#### Step 2 Apply the configuration

Apply manually

This command will deploy to argocd all the yaml files on the `argocd/templates` folder. If you testing ensure only a single file is listed.

```
#from alpine1
~/k3s-repository # helm template  argocd/ | kubectl apply -f -
application.argoproj.io/app-of-apps-platform configured

```



We have now deployed the first application on ArgoCD. We can now add the ArgoCD instance to be  managed by ArgoCD.



#### Add ArgoCD to `app-of-apps`

```
# from alpine1
#k3s-repository
cat << EOF > argocd/templates/argocd.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd  #application name must match helm application name
  namespace: app-of-apps
  finalizers:

  - resources-finalizer.argocd.argoproj.io
    spec:
    project: default
    source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: clusters/ctx-k3s-cluster-77/argo-cd-6.4.0
    targetRevision: HEAD
    destination:
    server: https://kubernetes.default.svc
    namespace: argocd
    syncPolicy:
    #automated:
      #selfHeal: true
    syncOptions:
    - CreateNamespace=true
      EOF

```

Push the change to the repository

```

# get the list of changed files.
git status 

# add the specific file created above.
git add argocd/templates/argocd.yaml

# commit the change with a message.
git commit -m " add ArgoCD to app-of-apps"

# git push
git push

#Once git push is done, it will take about 3 minutes for ArgoCD to poll the change.
As soon as the change is detected, ArgoCD will create a new tab for the ArgoCD application.

There is no need to perform a `kubectl apply` command.

```

We have now completed the ArgoCD deployments.







 

#### Other commands used to troubleshoot ArgoCD.

How to delete an ArgoCD application ?

download ArgoCD CLI

```
wget https://github.com/argoproj/argo-cd/releases/download/v2.4.14/argocd-linux-amd64
chmod +x argocd-linux-amd64

#sudo mv argocd-linux-amd64 /usr/local/bin/argocd
mv argocd-linux-amd64 /usr/local/bin/argocd
```

2. Use argocd command line 
```
#Set the default context to `argocd` namespace
kubectl config set-context --current --namespace=argocd
#login argocd to the current context
argocd login --core

# applications deployed can be viewed
argocd app list
NAME      CLUSTER     NAMESPACE  PROJECT  STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO
   PATH      TARGET
root-app  in-cluster  argocd     default  OutOfSync  Healthy  Auto        <none>      https://github.com/belajarpowershell/k3s-repository.git  root-app  HEAD
```

3.  Deleting argocd applications
```
# get app list 
~/k3s-repository # argocd app list | awk '{print $1", "$3,","$5}'
NAME, NAMESPACE ,STATUS
app-of-apps-platform, app-of-apps ,Synced
argocd, argocd ,Synced
imagepullsecret-patcher, imagepullsecret-patcher ,OutOfSync


# Delete application
argocd app delete imagepullsecret-patcher -n imagepullsecret-patcher 

namespace stuck in deleting
`argocd app list` will show the application being deleted.
 
# the delete comand will not complete due to the finalizers
# the following will remove the finalizers and allow the deletion to complete
#    kubectl patch app APP_NAME -n namespace -p '{"metadata": {"finalizers": null}}' --type merge
#    kubectl patch crd CRD_NAME -n namespace -p '{"metadata": {"finalizers": null}}' --type merge

kubectl patch app imagepullsecret-patcher -n imagepullsecret-patcher -p '{"metadata": {"finalizers": null}}' --type merge
```





