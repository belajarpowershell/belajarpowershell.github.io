#### Metallb

`https://rpi4cluster.com/k3s/k3s-nw-setting/#`

`kubectl get service ingress-nginx-controller --namespace=ingress-nginx` Loadbalancer will remain in pending state

#### Install from local helm charts. 
```
#Download Helm chart
helm repo add bitnami https://charts.bitnami.com/bitnami
helm pull   bitnami/metallb --version 5.0.2 # downloads to metallb-5.0.2.tgz

#Extract helm to folder

mkdir metallb-5.0.2
tar -xvf metallb-5.0.2.tgz --strip-components=1 -C \metallb-5.0.2

#Install from local helm chart.
helm install metallb-system ./metallb-5.0.2 -f ./metallb-5.0.2/values.yaml --namespace metallb-system --create-namespace 
```


#### Metal LB is setup now need to allocate the Loadbalancer IP
The following will create a Custom Resource (CR)

```
kubectl apply -f metallb-5.0.2/metallb-ip-range.yaml -n metallb-system

cat <<EOF > metallb-ip-range.yaml
# The address-pools lists the IP addresses that MetalLB is
# allowed to allocate. You can have as many
# address pools as you want.
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  # A name for the address pool. Services can request allocation
  # from a specific address pool using this name.
  name: k8s-lab-pool
  namespace: metallb-system
spec:
  # A list of IP address ranges over which MetalLB has
  # authority. You can list multiple ranges in a single pool, they
  # will all share the same settings. Each range can be either a
  # CIDR prefix, or an explicit start-end range of IPs.
  addresses:
  - 192.168.100.208-192.168.100.215

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: metallb-l2adv
  namespace: metallb-system
spec:
  ipAddressPools:
  - k8s-lab-pool
EOF

```



Validation is done when Ingress is deployed. Without metallb, the external IP will not be created. Ingress will now have an IP assigned



