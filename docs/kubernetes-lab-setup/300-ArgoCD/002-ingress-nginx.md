

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
mkdir ingress-nginx-4.10.0
#tar -xvf ingress-nginx-4.10.0.tgz #defaults to ingress-nginx
tar -xvf ingress-nginx-4.10.0.tgz --strip-components=1 -C \ingress-nginx-4.10.0

# Deploy manualy.
helm install ingress-nginx ./ingress-nginx-4.10.0 -f ./ingress-nginx-4.10.0/values.yaml --namespace ingress-nginx --create-namespace 
```



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
argo-events     IN      A       192.168.100.208
alerts          IN      A       192.168.100.208
thanos          IN      A       192.168.100.208
longhorn        IN      A       192.168.100.208

#restart dns service
rc-service named restart 
````







Deploy demo application to test ingress

https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html

```
apple.yaml
kind: Pod
apiVersion: v1
metadata:
  name: apple-app
  labels:
    app: apple
spec:
  containers:
    - name: apple-app
      image: hashicorp/http-echo
      args:
        - "-text=apple"

---

kind: Service
apiVersion: v1
metadata:
  name: apple-service
spec:
  selector:
    app: apple
  ports:
    - port: 5678 # Default port for image

```

```
banana.yaml
kind: Pod
apiVersion: v1
metadata:
  name: banana-app
  labels:
    app: banana
spec:
  containers:
    - name: banana-app
      image: hashicorp/http-echo
      args:
        - "-text=banana"

---

kind: Service
apiVersion: v1
metadata:
  name: banana-service
spec:
  selector:
    app: banana
  ports:
    - port: 5678 # Default port for image
```



Create ingress for the demo applications

```
fruit-ingress.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-apple
spec:
  rules:
  - host: apple.k8s.lab
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: apple-service
            port:
              number: 5678
  ingressClassName: nginx
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-banana
spec:
  rules:
  - host: banana.k8s.lab
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: banana-service
            port:
              number: 5678
  ingressClassName: nginx
```

```
Test 
Before tesing the following dns mapping must be updated on alpine1

vi /etc/bind/master/k8s.lab

apple           IN      A       192.168.100.208
banana          IN      A       192.168.100.208

#restart dns service
rc-service named restart 

# test for output. If the following is not returned check logs
$ curl -kL http://apple.k8s.lab/
apple

$ curl -kL http://banana.k8s.lab/
banana

$ curl -kL http://192.168.100.208/
404 Not Found


# logs to check 
 kubectl logs ingress-nginx-controller-6d9dfb8fd7-qmv9w -n ingress-nginx

```

