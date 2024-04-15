create root app

redo change name to app-of-apps-platform

```
$ mkdir -p k3s-repository/app-of-apps/templates
$ touch k3s-repository/app-of-apps/values.yaml


```

```

cat <<EOF > k3s-repository/app-of-apps/Chart.yaml

apiVersion: v2
name: app-of-apps-platform
version: 1.0.0
EOF
```



```
# This is to create the app of apps to be added to Argocd.

cat <<EOF > k3s-repository/app-of-apps/templates/app-of-apps-platform.yaml

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
    path: app-of-apps
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



Apply manually

This command will deploy to argocd all the yaml files on the `app-of-apps/templates` folder. If you testing ensure only a single file is listed.



```
helm template app-of-apps/ | kubectl apply -f -
```



```
how to delete argocd application ??


1. download argocd CLI

https://blog.differentpla.net/blog/2022/10/16/installing-argocd-cli/

2. 
 kubectl config set-context --current --namespace=argocd
argocd login --core

argocd app list
NAME      CLUSTER     NAMESPACE  PROJECT  STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO
   PATH      TARGET
root-app  in-cluster  argocd     default  OutOfSync  Healthy  Auto        <none>      https://github.com/belajarpowershell/k3s-repository.git  root-app  HEAD


3. did not need argocd cli.
Just to patch the app finalizers
kubectl patch app APP_NAME -p '{"metadata": {"finalizers": null}}' --type merge
kubectl patch crd CRD_NAME -p '{"metadata": {"finalizers": null}}' --type merge

## worked
kubectl patch app root-app -n argocd  -p '{"metadata": {"finalizers": null}}' --type merge

kubectl patch app root-app -n argocd  -p '{"metadata": {"finalizers": null}}' --type merge


##  namespace stuck in deleting
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n argocd


kubectl patch app application.argoproj.io/argo-cd -n argocd  -p '{"metadata": {"finalizers": null}}' --type merge
application.argoproj.io/argo-cd
```



kubectl patch namespace argocd -p '{"metadata":{"finalizers":[]}}' --type=merge

#### Once the root-app /app of apps is ready. We now add argocd to be managed with argocd



```
cat << EOF > k3s-repository/app-of-apps/templates/argocd.yaml
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



