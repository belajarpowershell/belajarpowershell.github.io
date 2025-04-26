

## Cert-manager and Private CA 

#### Deploy cert-manager ( for GKE to use Vault)

https://medium.com/geekculture/a-simple-ca-setup-with-kubernetes-cert-manager-bc8ccbd9c2

https://michalwojcik.com.pl/2021/08/08/ingress-tls-in-kubernetes-using-self-signed-certificates/

https://blog.differentpla.net/blog/2022/02/06/cert-manager/

```

helm repo add jetstack https://charts.jetstack.io
helm repo update
```

#### Install from remote helm charts.

````

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true --version v1.14.4

````





ArgoCD application-cert-manager ( app of apps deployment points to this manifest for deployment)

Cluster specific configuration

k3s1/

```
{
  name:"k3s1" 
  clusterName: "k3s1.k8s.lab",
  any_other_info: "some_cluster_specific_data"
}

```



k3s1/apps/certmanager/deploy.jsonnet

```
// Import cluster settings
local config = import "../../../k3s1/cluster.jsonnet";  // Define config

// Import the cert-manager template and pass config
local certManagerApp = import "../../../libs/cert-manager/cert-manager.jsonnet";

certManagerApp(config)  // Call the function with config

```



[Common code used by all deployments hosted in libs/ folder]

libs/cert-manager/cert-manager.jsonnet

```
// cert-manager.jsonnet (in libs/cert-manager)
local certManagerApp = function(config){  // Accept config as a parameter
  apiVersion: "argoproj.io/v1alpha1",
  kind: "Application",
  metadata: {
    name: "cert-manager",
    namespace: "argocd",
  },
  spec: {
    destination: {
      server: "https://" + config.clusterName + ":6443",  // Use the passed config
      namespace: "cert-manager",
    },
    project: "platform-component",
    source: {
      chart: "cert-manager",
      repoURL: "https://charts.jetstack.io",
      targetRevision: "v1.14.4",
      helm: {
        values: |||
          installCRDs: true
        |||,
      },
    },
    syncPolicy: {
      automated: {
        prune: true,
        selfHeal: true,
      },
      syncOptions: ["CreateNamespace=true"],
    },
  },
};

// Export the function
certManagerApp


```



```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cert-manager
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: cert-manager
  project: default
  source:
    chart: cert-manager
    repoURL: https://charts.jetstack.io
    targetRevision: v1.14.4  # Update this to the latest stable version if needed
    helm:
      values: |
        installCRDs: true
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```



###Push code to repo

###Enable app of apps ( one time apply)

Scans folder for yaml/jsonnet/helm configuration

<platform-app-of-apps.yaml>

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-app-of-apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git  # Your Git repo
    targetRevision: main
    path: k3s1/apps  # Points to Jsonnet files
    directory:
      recurse: true  # Ensure all Jsonnet files are processed
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  # syncPolicy:
  #   automated:
  #     prune: true
  #     selfHeal: true
  #   syncOptions:
  #     - CreateNamespace=true
```

kubectl apply -f platform-app-of-apps.yaml

This will fail , as the cluster k3s1 is not added to ArgoCD. i.e. ArgoCD does not have access.

If the following destination was used this will work.

```
...
destination:
    server: https://kubernetes.default.svc
...
```





`Nb : use namespace cert-manager`

`cert-manager` is now installed. 

To configure `cert-manager`  a certificate authority is required. In production networks you can use  providers like `lets-encrypt`  but that added complexity as you will need a valid domain name . As this lab is to test deployments we can use self signed certificates. They function just as a public CA but they are not recognized by the web browsers.

