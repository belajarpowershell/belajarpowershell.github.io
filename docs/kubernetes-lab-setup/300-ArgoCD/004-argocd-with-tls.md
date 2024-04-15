https://www.arthurkoziel.com/setting-up-argocd-with-helm/

#### Install argocd command line

```
wget https://github.com/argoproj/argo-cd/releases/download/v2.4.14/argocd-linux-amd64
chmod +x argocd-linux-amd64
#sudo mv argocd-linux-amd64 /usr/local/bin/argocd
mv argocd-linux-amd64 /usr/local/bin/argocd

```

#### Update values.yaml

```
Update values.yaml to 
- enable ingress
 

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


####  Relevant `values.yaml` to update

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

#### Deploy from local helm chart

```
helm repo add argo https://argoproj.github.io/argo-helm
helm pull argo/argo-cd --version 6.4.0 

mkdir argo-cd-6.4.0
tar -xvf argo-cd-6.4.0.tgz --strip-components=1 -C \argo-cd-6.4.0

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
longhorn    IN      A       192.168.100.208

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





##### Other values.yaml to update

to enable tls for ArgoCD

row 2028

```
tls:false # true
```



rows 1849

```
  # TLS certificate configuration via cert-manager                                                                                                                                                                    ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#tls-certificates-used-by-argocd-server                                                                                                        certificate:                                                                                                                                                                                                          # -- Deploy a Certificate resource (requires cert-manager)                                                                                                                                                          enabled: false >> True                                                                                                                                                                                                     # -- The name of the Secret that will be automatically created and managed by this Certificate resource                                                                                                             secretName: argocd-server-tls                                                                                                                                                                                       # -- Certificate primary domain (commonName)                                                                                                                                                                        # @default -- `""` (defaults to global.domain)                                                                                                                                                                      domain: ""                                                                                                                                                                                                          # -- Certificate Subject Alternate Names (SANs)                                                                                                                                                                     additionalHosts: []                                                                                                                                                                                                 # -- The requested 'duration' (i.e. lifetime) of the certificate.                                                                                                                                                   # @default -- `""` (defaults to 2160h = 90d if not specified)
    ## Ref: https://cert-manager.io/docs/usage/certificate/#renewal
    duration: ""
    # -- How long before the expiry a certificate should be renewed.
    # @default -- `""` (defaults to 360h = 15d if not specified)                                                                                                                                                        ## Ref: https://cert-manager.io/docs/usage/certificate/#renewal
    renewBefore: ""
    # Certificate issuer
    ## Ref: https://cert-manager.io/docs/concepts/issuer
    issuer:
      # -- Certificate issuer group. Set if using an external issuer. Eg. `cert-manager.io`
      group: ""
      # -- Certificate issuer kind. Either `Issuer` or `ClusterIssuer`
      kind: ""
      # -- Certificate issuer name. Eg. `letsencrypt`
      name: ""
    # Private key of the certificate
    privateKey:
      # -- Rotation policy of private key when certificate is re-issued. Either: `Never` or `Always`
      rotationPolicy: Never
      # -- The private key cryptography standards (PKCS) encoding for private key. Either: `PCKS1` or `PKCS8`
      encoding: PKCS1
      # -- Algorithm used to generate certificate private key. One of: `RSA`, `Ed25519` or `ECDSA`
      algorithm: RSA
      # -- Key bit size of the private key. If algorithm is set to `Ed25519`, size is ignored.
      size: 2048
    # -- Annotations to be applied to the Server Certificate
    annotations: {}
    # -- Usages for the certificate
    ### Ref: https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.KeyUsage
    usages: []

  # TLS certificate configuration via Secret
  ## Ref: https://argo-cd.readthedocs.io/en/stable/operator-manual/tls/#tls-certificates-used-by-argocd-server
  certificateSecret:
    # -- Create argocd-server-tls secret
    enabled: false
    # -- Annotations to be added to argocd-server-tls secret
    annotations: {}
    # -- Labels to be added to argocd-server-tls secret
    labels: {}
    # -- Private Key of the certificate
    key: ''
    # -- Certificate data
    crt: ''

```







