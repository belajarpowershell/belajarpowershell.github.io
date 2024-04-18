## no jsonnet

## using helm





https://medium.com/@harshaljethwa19/deploying-an-application-to-argocd-using-helm-part-2-of-ci-cd-using-argocd-cd6a6c7a3047

```
helm repo add stable https://charts.helm.sh/stable

```

Install ingress-nginx

```
kubectl create namespace ingress-nginx

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.10.0 -n ingress-nginx

#remove
helm uninstall ingress-nginx ingress-nginx/ingress-nginx

```



Metallb

`https://rpi4cluster.com/k3s/k3s-nw-setting/#`

`kubectl get service ingress-nginx-controller --namespace=ingress-nginx` Loadbalancer will remain in pending state

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm pull my-metallb --repo https://charts.bitnami.com/bitnami --version 4.15.0 

helm install my-metallb bitnami/metallb --version 4.15.0 --namespace metallb --create-namespace


# once metal LB is setup now need to allocate the Loadbalancer IP
this will create a Custom Resource (CR)
kubectl apply -f metallb-ip-range.yaml -n metallb


# The address-pools lists the IP addresses that MetalLB is
# allowed to allocate. You can have as many
# address pools as you want.
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  # A name for the address pool. Services can request allocation
  # from a specific address pool using this name.
  name: k8s-lab-pool
spec:
  # A list of IP address ranges over which MetalLB has
  # authority. You can list multiple ranges in a single pool, they
  # will all share the same settings. Each range can be either a
  # CIDR prefix, or an explicit start-end range of IPs.
  addresses:
  - 192.168.100.208-192.168.100.215



```



Ingress will now have an IP assigned

![image-20240320232449161](C:/Users/suresh/AppData/Roaming/Typora/typora-user-images/image-20240320232449161.png)





Deploy ArgoCD

https://www.arthurkoziel.com/setting-up-argocd-with-helm/



```
Update values.yaml to 

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

#to remove
helm uninstall argocd argo/argo-cd --version 6.4.0

```
Configure Ingress for Argocd



```
get ingress class name


```



arogcd-ingress.yaml

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    alb.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: argocd-server
            port:
              name: http
    host: argo.org.local

```

scratch

```
Row 1996
  # Argo CD server ingress configuration
  ingress:
    # -- Enable an ingress resource for the Argo CD server
    enabled: true #false ###<< SS updated
    # -- Specific implementation for ingress controller. One of `generic`, `aws` or `gke`
    ## Additional configuration might be required in related configuration sections
    controller: generic
    # -- Additional ingress labels
    labels: {}
    # -- Additional ingress annotations
    ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-1-ssl-passthrough
    annotations: {}
      # nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      # nginx.ingress.kubernetes.io/ssl-passthrough: "true"

    # -- Defines which ingress controller will implement the resource
    ingressClassName: "nginx" ###<< SS updated



############
row 872
## Dex
dex:
  # -- Enable dex
  enabled: false #true

###############
row 2920
  # Argo CD server ingress configuration
  ingress:
    # -- Enable an ingress resource for the Argo CD server
    enabled: true #false
    # -- Specific implementation for ingress controller. One of `generic`, `aws` or `gke`
    ## Additional configuration might be required in related configuration sections
    controller: generic
    # -- Additional ingress labels
    labels: {}
    # -- Additional ingress annotations
    ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-1-ssl-passthrough
    annotations: {}
      # nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      # nginx.ingress.kubernetes.io/ssl-passthrough: "true"

    # -- Defines which ingress controller will implement the resource
    ingressClassName: ""
##########
row 2921
## Notifications controller
notifications:
  # -- Enable notifications controller
  enabled: false

##################
row2565

## ApplicationSet controller
applicationSet:
  # -- Enable ApplicationSet controller
  enabled: true

##################

row 1625
server:
  # -- Additional command line arguments to pass to Argo CD server
  extraArgs: 
    - --insecure

####



```

