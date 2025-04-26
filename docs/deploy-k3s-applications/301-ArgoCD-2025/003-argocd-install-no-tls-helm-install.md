install argocd from alpine1 using Helm

no TLS

```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --version 4.10.0 \
  --namespace argocd --create-namespace \
  --set dex.enabled=false \
  --set notifications.enabled=false \
  --set applicationSet.enabled=true \
  --set server.ingress.enabled=true \
  --set server.ingress.hostname="argocd1.k8s.lab" \
  --set server.ingress.ingressClassName=nginx \
  --set global.domain=k8s.lab \
  --set server.extraArgs={--insecure} \
  --set server.insecure=true \
  --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/backend-protocol"="HTTP" \
  --set configs.secret.argocdServerAdminPassword='$2b$12$3peDOQrx3EVLpfCJ.lRQQOSVNBiyjbJ0ofT79qrsdJvU9eTBG.mFm' \
  --set configs.secret.argocdServerAdminPasswordMtime="$(date +%FT%T%Z)"  

#argocdServerAdmin=admin
#argocdServerAdminPassword=YourSecurePassword


helm uninstall argocd -n argocd
```



ArgoCD URL

get admin secret

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Access on

```
https://argocd1.k8s.lab/
```

# Deploy using Jsonnet

from

`argocd-master/k3s1/helm`

```

# 1. Ensure the templates directory exists
mkdir -p ./templates

# 2. Run jsonnet to generate files, using `-m .` to output multiple files into the current directory
jsonnet -m . helm-chart.libsonnet

# 3. Build Helm chart dependencies (if any are defined in Chart.yaml)
helm dependency build

# 4. If the file './templates/_templates.jsonnet' exists, render it and output the result to templates.yaml
if [ -f './templates/_templates.jsonnet' ]; then
  jsonnet ./templates/_templates.jsonnet > ./templates/templates.yaml
fi


```



```
# Render the Helm chart templates and apply them directly to the cluster
helm template k3s1-argocd . \
  --api-versions monitoring.coreos.com/v1 \
  --api-versions networking.k8s.io/v1/Ingress \
  --namespace argocd \
  --include-crds | \
  kubectl apply -n argocd -f -



helm template k3s1-argocd . \
  --api-versions monitoring.coreos.com/v1 \
  --api-versions networking.k8s.io/v1/Ingress \
  --namespace argocd \
  --include-crds  > temp.json
```







### Add k3s2 to argocd -via argcd cli

```.
#ensure in the master cluster context must be default in argocd namespace

kubectl config set-context k3s1 --namespace=argocd
argocd login --core

#add cluster name as in kubeconfig
argocd cluster add k3s1
```

