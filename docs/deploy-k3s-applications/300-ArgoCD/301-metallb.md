One of the first services to deploy on a High Availability clusters will be the a Load Balancer. The Load balancer functions to provide External IP addresses to the `Ingress` service. 

The Load balancer `Metallb` will be used. 

#### Metallb

#### Helm Charts

I have selected to deploy using Helm Charts, as this is a well used method and prefered. Helm Chart basically sets up all related configuration to get the application to be installed working. Helm Charts also work with ARGO CD, another tool That I will be deploying. The method to use the Helm Charts, are to download the Helm Charts locally and references from a local repository rather than pulling directly from the public repositories.

#### Install from local helm charts. 

The following commands are done from  `k3s-repository/clusters/ctx-k3s-cluster-77`

```
#Download Helm chart
helm repo add bitnami https://charts.bitnami.com/bitnami
helm pull   bitnami/metallb --version 5.0.2 # downloads to metallb-5.0.2.tgz

#Extract helm to folder \metallb-5.0.2
mkdir metallb-5.0.2 && tar -xvf metallb-5.0.2.tgz --strip-components=1 -C \metallb-5.0.2

#Install from local helm chart.
helm install metallb-system ./metallb-5.0.2 -f ./metallb-5.0.2/values.yaml --namespace metallb-system --create-namespace 
```

At this time the pods in the `metallb-system` will have been created

```
kubectl get pods -n metallb-system
NAME                                         READY   STATUS    RESTARTS       AGE
metallb-system-controller-5f7c4d88cf-k5cct   1/1     Running   7 (6d4h ago)   9d
metallb-system-speaker-6p6ft                 1/1     Running   1 (7d1h ago)   9d
metallb-system-speaker-gsv4c                 1/1     Running   5 (13h ago)    9d
metallb-system-speaker-m45j4                 1/1     Running   2 (7d8h ago)   9d

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



#### A few points to take note of

- The `metallb` application was deployed using Helm .
- The `metallb` configuration was applied using `kubectl apply -f metallb-5.0.2/metallb-ip-range.yaml -n metallb-system ` 
- This is not an efficient method. But for first time users, it will help to state this.
- `metallb` will be deployed 
