1

Install curl

```
apk update 
apk search curl
apk add curl 
```







Install helm

```
apk add helm

```



from repository 

`https://github.com/belajarpowershell/k3s-repository`

create folder 

`argocd`





download helm chart 

```
helm repo add argo https://argoproj.github.io/argo-helm

helm pull --repo https://argoproj.github.io/argo-helm --version 6.4.0

helm pull  my-argo-cd argo/argo-cd --version 6.6.0


```

