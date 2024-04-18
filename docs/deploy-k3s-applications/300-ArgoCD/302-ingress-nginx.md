The next service to Install is `ingress-nginx` .  Ingress services are to expose the Kubernetes services to external networks.

Kubernetes services by default cannot be accessed out side of the cluster. Ingress allows these to be accessible externally.

Do take note there are 2 different applications with similar name

`ingress-nginx` is the community driven instance

`nginx-ingress` is the official Nginx supported image. 

In this example we are using `ingress-nginx`.

#### Install ingress-nginx

```
kubectl create namespace ingress-nginx

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.10.0 -n ingress-nginx

#remove
helm uninstall ingress-nginx -n ingress-nginx

```



#### install from local helm charts. 
```

#Download helm chart
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm pull   ingress-nginx/ingress-nginx --version 4.10.0 # downloads to metallb-5.0.2.tgz

#Extract helm to folder
mkdir ingress-nginx-4.10.0 && tar -xvf ingress-nginx-4.10.0.tgz --strip-components=1 -C \ingress-nginx-4.10.0

# Deploy manualy.
helm install ingress-nginx ./ingress-nginx-4.10.0 -f ./ingress-nginx-4.10.0/values.yaml --namespace ingress-nginx --create-namespace 
```



#### Ingress and DNS



Ingress has a dependency on DNS , the FQDN configured in the Ingress configuration must be resolvable via DNS ( or hosts file).

As we have a working DNS setup, we can add some hostnames to be resolved. 



#### Register DNS names.

````
Update on alpine1 
vi /etc/bind/master/k8s.lab

# add the following entries
apple           IN      A       192.168.100.208
banana          IN      A       192.168.100.208
prometheues     IN      A       192.168.100.208
metrics         IN      A       192.168.100.208
grafana         IN      A       192.168.100.208
rollouts        IN      A       192.168.100.208
argocd		    IN      A       192.168.100.208
alerts          IN      A       192.168.100.208
thanos          IN      A       192.168.100.208
longhorn        IN      A       192.168.100.208

#restart dns service
rc-service named restart 
````



To test the ingress service try some demo application to test ingress. Refer to the following URL.

https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html

