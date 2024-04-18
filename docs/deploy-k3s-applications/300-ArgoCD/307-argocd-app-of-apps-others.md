

# More examples on `app-of-app`

In this example Prometheus is deployed using `app-of-apps` . This slightly different as the Promethues has a Persistent storage requirement. 

Kubernetes pods are by design temporary, when the pod is deleted all data is also lost. 

If the data is required to be maintained persistent storage is required. This is where Longhorn's role steps in.





#### Step 1 download helm chart

```

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm pull  prometheus-community/prometheus --version v25.18.0

mkdir prometheus-25.18.0
tar -xvf prometheus-25.18.0.tgz --strip-components=1 -C \prometheus-25.18.0

# Install from remote helm charts.
helm install prometheus -f prometheus-25.18.0/values.yaml prometheus-community/prometheus:25.18.0 --namespace prometheus --create-namespace --set installCRDs=true


# install from local helm charts. 
helm install prometheus ./prometheus-25.18.0 -f ./prometheus-25.18.0/values.yaml --namespace prometheus --create-namespace --set installCRDs=true


Values.yaml
-storageclass 
- PVC size

```

```

cat << EOF > app-of-apps/templates/prometheus.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: clusters/ctx-k3s-cluster-77/prometheus-25.18.0
    targetRevision: HEAD
    helm:
      valueFiles:
      - values.yaml
      values: |
        pushgateway:
          enabled: false
      releaseName: prometheus
      parameters:
      - name: app
        value: prometheus
  destination:
    server: https://kubernetes.default.svc
    namespace: prometheus
  syncPolicy:
    #automated:
      #selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF



```

Try on imagepull secrets



```
helm repo add empathyco https://empathyco.github.io/helm-charts/

helm install my-imagepullsecret-patcher empathyco/imagepullsecret-patcher --version 1.0.0


helm repo update

helm pull  empathyco/imagepullsecret-patcher --version 1.0.0

mkdir imagepullsecret-patcher-1.0.0
tar -xvf imagepullsecret-patcher-1.0.0.tgz --strip-components=1 -C \imagepullsecret-patcher-1.0.0

```

THis only updates the root-app application. Does not create deployment

```
cat << EOF > app-of-apps/templates/imagepullsecret-patcher.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: imagepullsecret-patcher
  namespace: argocd  ### this namespace must be argocd ns.
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: clusters/ctx-k3s-cluster-77/imagepullsecret-patcher-1.0.0
    targetRevision: HEAD
    helm:
      valueFiles:
      - values.yaml
      releaseName: imagepullsecret-patcher
      parameters:
      - name: app
        value: imagepullsecret-patcher

  destination:
    server: https://kubernetes.default.svc
    namespace: imagepullsecret-patcher
  syncPolicy:
    #automated:
      #selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
```

Check if manual deploy works



```

helm install imagepullsecret-patcher ./imagepullsecret-patcher-1.0.0 -f ./imagepullsecret-patcher-1.0.0/values.yaml --namespace imagepullsecret-patcher --create-namespace --set installCRDs=true

```



Deploy already installed

````
cat << EOF > app-of-apps/templates/cert-manager-existing.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cert-manager
  namespace: argocd  ### this namespace must be argocd ns.
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: clusters/ctx-k3s-cluster-77/cert-manager-v1.14.4
    targetRevision: HEAD
    helm:
      valueFiles:
      - values.yaml
      releaseName: cert-manager
      parameters:
      - name: app
        value: cert-manager

  destination:
    server: https://kubernetes.default.svc
    namespace: cert-manager
  syncPolicy:
    #automated:
      #selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

````

