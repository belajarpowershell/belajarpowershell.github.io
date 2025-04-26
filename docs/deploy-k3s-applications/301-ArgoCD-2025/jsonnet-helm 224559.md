Performed on cluster folder

`argocd-master/k3s1/helm/helm-chart.libsonnet`

Create Chart.yaml and values.yaml

```
jsonnet -m .  helm-chart.libsonnet 
```

Download the files required.

```
helm dependancy build
```



Deploy the application

```
/bin/sh -c "helm template $ARGOCD_APP_NAME . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace $ARGOCD_APP_NAMESPACE"


helm template argocd . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace argocd

```

