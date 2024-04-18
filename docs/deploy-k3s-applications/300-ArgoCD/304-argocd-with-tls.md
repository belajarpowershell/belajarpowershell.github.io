### ArgoCD deployment.

https://www.arthurkoziel.com/setting-up-argocd-with-helm/

We have deployed the core services required for ArgoCD. 



#### Install argocd command line

```
# on alpine1

wget https://github.com/argoproj/argo-cd/releases/download/v2.4.14/argocd-linux-amd64
chmod +x argocd-linux-amd64

#sudo mv argocd-linux-amd64 /usr/local/bin/argocd
mv argocd-linux-amd64 /usr/local/bin/argocd

```



####  Relevant `values.yaml` to update

To ensure when installation with helm includes the ingress creation, the `values.yaml` must be updated with some key values.  This is where the custom configurations are placed.

There are a few key values that must be updated.

Search the `values.yaml` for the following branch and update with values. 

```

## search dex:
dex:
  # -- Enable dex
  enabled: false #true
  
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
argocd # update 

##search global:
global:
  # -- Default domain used by all components
  ## Used for ingresses, certificates, SSO, notifications, etc.
  domain: argocd.k8s.lab  ## update the argocd FQDN. Not sure if this is best practice.
 certificate:                                                                                                
 ##search cert-manager
   # TLS certificate configuration via cert-manager
server
  certificate:
    # -- Deploy a Certificate resource (requires cert-manager)
    enabled: true # change from false  
    secretName: argocd-server-tls
    issuer:
      # -- Certificate issuer kind. Either `Issuer` or `ClusterIssuer`
      kind: "clusterIssuer" # update with as configured in cert-manager
      # -- Certificate issuer name. Eg. `letsencrypt`
      name: "ca-issuer-k8s-lab"   # update with as configured in cert-manager s                                                                        

```



#### Deploy from local helm chart

```
helm repo add argo https://argoproj.github.io/argo-helm
helm pull argo/argo-cd --version 6.4.0 
 
mkdir argo-cd-6.4.0 && tar -xvf argo-cd-6.4.0.tgz --strip-components=1 -C \argo-cd-6.4.0

# install from local helm charts. 
helm install argocd ./argo-cd-6.4.0 -f ./argo-cd-6.4.0/values.yaml --namespace argocd --create-namespace --set installCRDs=true

## to update helm values
helm upgrade -f ./argo-cd-6.4.0/values.yaml  argocd argo/argo-cd --version 6.4.0 -n argocd --reuse-values 

```

#### Register DNS names.

````
Update on alpine1 
vi /etc/bind/master/k8s.lab

# add the following entries
argocd    IN      A       192.168.100.208

#restart dns service
rc-service named restart 
````

#### ArgoCD URL

Open url `http://argocd.k8s.lab`  Will prompt for username and password.

```
user : admin
password: get from command below.

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

```



We have now succesfully deployed ArgoCD. 







