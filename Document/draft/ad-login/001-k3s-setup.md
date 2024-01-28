In order for the k3s to recoginize the autenthication token, 
the k3s service needs to be started with the OIDC issuer configuation

```
curl -sfL https://get.k3s.io | \
INSTALL_K3S_VERSION="v1.24.6+k3s1" \
--write-kubeconfig-mode 644 \
--tls-san "singleubuntu" \
--disable "traefik" \
--kube-apiserver-arg "oidc-issuer-url="https://sts.windows.net/a01c77f7-d822-4d88-88fd-9a738c46e3ab" \
--kube-apiserver-arg "oidc-client-id="spn:12138e8b-b64f-4bb3-b9f3-a944f24f0c7d" \
--kube-apiserver-arg "oidc-username-claim=upn" \
--kube-apiserver-arg "oidc-groups-claim=groups" \
--kube-apiserver-arg "oidc-username-prefix=aad:" \
--kube-apiserver-arg "oidc-groups-prefix=aad:" \
--kube-apiserver-arg "audit-log-path=/var/log/kubernetes/audit/audit.log" \
--kube-apiserver-arg "audit-policy-file=/var/lib/rancher/k3s/server/manifests/audit.yaml" \
--kube-apiserver-arg "audit-log-maxsize=100" \
--kube-apiserver-arg "audit-log-maxbackup=30"
```
--kube-apiserver-arg "oidc-ca-file=/var/lib/rancher/k3s/server/tls/server-ca.crt"
```
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_VERSION="v1.24.6+k3s1" \
  sh -s - server \
  --write-kubeconfig-mode 644 \
  --tls-san "{{INSERT LOAD BALANCER VM HOSTNAME HERE}}" \
  --cluster-init \
  --node-taint CriticalAddonsOnly=true:NoExecute \
  --disable "traefik" \
  --disable "local-storage" \
  --disable "servicelb" \
  --kube-apiserver-arg "oidc-issuer-url=https://sts.windows.net/41875f2b-33e8-4670-92a8-f643afbb243a/" \
  --kube-apiserver-arg "oidc-client-id=spn:bf07ce73-75d7-4a5f-8a27-7975e258b674" \
  --kube-apiserver-arg "oidc-username-claim=upn" \
  --kube-apiserver-arg "oidc-groups-claim=groups" \
  --kube-apiserver-arg "oidc-username-prefix=aad:" \
  --kube-apiserver-arg "oidc-groups-prefix=aad:" \
  --kube-apiserver-arg "audit-log-path=/var/log/kubernetes/audit/audit.log" \
  --kube-apiserver-arg "audit-policy-file=/var/lib/rancher/k3s/server/manifests/audit.yaml" \
  --kube-apiserver-arg "audit-log-maxsize=100" \
  --kube-apiserver-arg "audit-log-maxbackup=30"
  
  
  curl -sfL https://get.k3s.io | \
  INSTALL_K3S_VERSION="v1.23.5+k3s1" \
  sh -s - \
  --write-kubeconfig-mode 644 \
  --tls-san "x9149.prd.it29m.skf.io" \
  --disable "traefik" \
  --kube-apiserver-arg "oidc-issuer-url=https://sts.windows.net/41875f2b-33e8-4670-92a8-f643afbb243a/" \
  --kube-apiserver-arg "oidc-client-id=spn:bf07ce73-75d7-4a5f-8a27-7975e258b674" \
  --kube-apiserver-arg "oidc-username-claim=upn" \
  --kube-apiserver-arg "oidc-groups-claim=groups" \
  --kube-apiserver-arg "oidc-username-prefix=aad:" \
  --kube-apiserver-arg "oidc-groups-prefix=aad:"
```

- --oidc-ca-file=/var/lib/rancher/k3s/serverserver-ca.crt

#### Troubleshooting
```

Service is loaded from 
/etc/systemd/system/k3s.service
journalctl -u k3s | grep -i -E 'OIDC|OpenID|authentication'
journalctl -u k3s -n 100
sudo systemctl restart systemd-journald

```
```
kubectl config set-cluster ctx-k3s-single-lab-02 --insecure-skip-tls-verify=true
```
k3s-single-lab-02 --insecure-skip-tls-verify=true
kubectl config set-cluster k3s-single-lab-02 --insecure-skip-tls-verify=true
