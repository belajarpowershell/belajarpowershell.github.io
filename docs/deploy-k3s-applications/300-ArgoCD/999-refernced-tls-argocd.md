https://www.arthurkoziel.com/setting-up-argocd-with-helm/



```
Update values.yaml to 
search for term 'ingressClassName' update with ingress class name
values.yaml
argo-cd:
  dex: # row 872
    enabled: false
  notifications: #row 2921
    enabled: false
  applicationSet: #row2565
    enabled: false
  server: #row 1625
    extraArgs:
      - --insecure
```
```
kubectl create namespace argocd


helm install argo-cd argo/argo-cd --version 6.4.0
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd --version 6.4.0 -n argocd
helm install -f values.yaml  argocd argo/argo-cd --version 6.4.0 -n argocd
#to remove
helm uninstall argocd argo/argo-cd 

################

# install from local helm charts. 
helm install argocd ./cert-manager-v1.14.4 -f ./cert-manager-v1.14.4/values.yaml --namespace cert-manager --create-namespace --set installCRDs=true

# install from local helm charts. 
helm install my-cert-manager ./cert-manager-v1.14.4 -f ./cert-manager-v1.14.4/values.yaml --namespace cert-manager --create-namespace --set installCRDs=true

```


To ensure when installation with helm includes the ingress creation, the `values.yaml` must be updated with some key values. 

```
Search for the following branch and update with values

## search dex:
dex:
  # -- Enable dex
  enabled: false #true
  
## search ingressClassName:
ingressClassName: "" # update with ingress class name. 

##search notifications:
notifications:
  # -- Enable notifications controller
  enabled: false

##search applicationSet:
applicationSet:
  # -- Enable ApplicationSet controller
  enabled: true

##search server:
server:
  # -- Additional command line arguments to pass to Argo CD server
  extraArgs: 
    - --insecure     # this is to disable tls certificate requirements when opened in the browser
##search ingress:    
  ingress:
    # -- Defines which ingress ApplicationSet controller will implement the resource
    ingressClassName: "nginx"
    tls: false   # to disable tls
##search hostname:
argocd

##search global:
global:
  # -- Default domain used by all components
  ## Used for ingresses, certificates, SSO, notifications, etc.
  domain: argocd.k8s.lab  ## update the argocd FQDN. Not sure if this is best practice.


```



Open url `http://argocd.k8s.lab`  Will prompt for username and password.

```
user : admin
password: get from command below.
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

```









