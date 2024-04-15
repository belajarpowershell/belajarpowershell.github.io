

## cert-manager and Private CA 

#### Deploy cert-manager

https://medium.com/geekculture/a-simple-ca-setup-with-kubernetes-cert-manager-bc8ccbd9c2

https://michalwojcik.com.pl/2021/08/08/ingress-tls-in-kubernetes-using-self-signed-certificates/

https://blog.differentpla.net/blog/2022/02/06/cert-manager/

```

helm repo add jetstack https://charts.jetstack.io
helm repo update
```

#### Install from remote helm charts.

````


helm install my-cert-manager -f cert-manager-v1.14.4/values.yaml jetstack/cert-manager:v1.14.4 --namespace certmanager --create-namespace --set installCRDs=true
````

#### install from local helm charts. 
```
# download Helm Chart
helm pull   jetstack/cert-manager --version 1.14.4

# extract Helm chart locally
mkdir cert-manager-v1.14.4
tar -xvf cert-manager-v1.14.4.tgz --strip-components=1 -C \cert-manager-v1.14.4

# install Helm chart 
helm install cert-manager ./cert-manager-v1.14.4 -f ./cert-manager-v1.14.4/values.yaml --namespace cert-manager --create-namespace --set installCRDs=true

````





```
#to remove
# list helm charts
# helm list -A
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /root/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /root/.kube/config
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
argocd          argocd          1               2024-03-22 20:47:41.189234683 +0800 +08 deployed        argo-cd-6.4.0           v2.10.1
ingress-nginx   ingress-nginx   1               2024-03-22 08:17:15.347695124 +0800 +08 deployed        ingress-nginx-4.10.0    1.10.0
my-cert-manager certmanager     1               2024-03-22 23:15:15.494559378 +0800 +08 deployed        cert-manager-v1.14.4    v1.14.4
my-metallb      metallb         1               2024-03-04 07:12:29.440645002 +0800 +08 deployed        metallb-4.15.0          0.14.3

# uninstall 
helm uninstall my-cert-manager  -n cert-manager
```

`Nb : use namespace cert-manager`

Once the certmanager is installed. 

Create a CA ( self signed Certificate Authority)



####  Deploy private CA on Kubernetes (working)

https://cert-manager.io/docs/configuration/ca/

Create Key pair secret.

( this is example key pair, for production to use openssl o generate new key pair.)

```
## cannot use this method to save file cat <<EOF > 01-ca-key-pair-k8s-lab.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ca-key-pair-k8s-lab
  namespace: cert-manager
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMrVENDQWVHZ0F3SUJBZ0lKQUtQR3dLRGwvNUhuTUEwR0NTcUdTSWIzRFFFQkN3VUFNQk14RVRBUEJnTlYKQkFNTUNHcHZjMmgyWVc1c01CNFhEVEU1TURneU1qRTJNRFUxT0ZvWERUSTVNRGd4T1RFMk1EVTFPRm93RXpFUgpNQThHQTFVRUF3d0lhbTl6YUhaaGJtd3dnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCCkFRQ3doU0IvcVc2L2tMYjJ6cHUrRUp2RDl3SEZhcStRQS8wSkgvTGxseW83ekFGeCtISHErQ09BYmsrQzhCNHQKL0hVRXNuczVSTDA5Q1orWDRqNnBiSkZkS2R1UHhYdTVaVllua3hZcFVEVTd5ZzdPU0tTWnpUbklaNzIzc01zMApSNmpZbi9Ecmo0eFhNSkVmSFVEcVllU1dsWnIzcWkxRUZhMGM3ZlZEeEgrNHh0WnROTkZPakg3YzZEL3ZXa0lnCldRVXhpd3Vzc2U2S01PV2pEbnYvNFZyamVsMlFnVVlVYkhDeWVaSG1jdGkrSzBMV0Nmby9SZzZQdWx3cmJEa2gKam1PZ1l0MzBwZGhYME9aa0F1a2xmVURIZnA4YmpiQ29JMnRhWUFCQTZBS2pLc08zNUxBRVU3OUNMMW1MVkh1WgpBQ0k1VWppamEzVlBXVkhTd21KUEp5dXhBZ01CQUFHalVEQk9NQjBHQTFVZERnUVdCQlFtbDVkVEFaaXhGS2hqCjkzd3VjUldoYW8vdFFqQWZCZ05WSFNNRUdEQVdnQlFtbDVkVEFaaXhGS2hqOTN3dWNSV2hhby90UWpBTUJnTlYKSFJNRUJUQURBUUgvTUEwR0NTcUdTSWIzRFFFQkN3VUFBNElCQVFCK2tsa1JOSlVLQkxYOHlZa3l1VTJSSGNCdgpHaG1tRGpKSXNPSkhac29ZWGRMbEcxcFpORmpqUGFPTDh2aDQ0Vmw5OFJoRVpCSHNMVDFLTWJwMXN1NkNxajByClVHMWtwUkJlZitJT01UNE1VN3ZSSUNpN1VPbFJMcDFXcDBGOGxhM2hQT2NSYjJ5T2ZGcVhYeVpXWGY0dDBCNDUKdEhpK1pDTkhCOUZ4alNSeWNiR1lWaytUS3B2aEphU1lOTUdKM2R4REthUDcrRHgzWGNLNnNBbklBa2h5SThhagpOVSttdzgvdG1Sa1A0SW4va1hBUitSaTBxVW1Iai92d3ZuazRLbTdaVXkxRllIOERNZVM1TmtzbisvdUhsUnhSClY3RG5uMDM5VFJtZ0tiQXFONzJnS05MbzVjWit5L1lxREFZSFlybjk4U1FUOUpEZ3RJL0svQVRwVzhkWAotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBc0lVZ2Y2bHV2NUMyOXM2YnZoQ2J3L2NCeFdxdmtBUDlDUi95NVpjcU84d0JjZmh4CjZ2Z2pnRzVQZ3ZBZUxmeDFCTEo3T1VTOVBRbWZsK0krcVd5UlhTbmJqOFY3dVdWV0o1TVdLVkExTzhvT3praWsKbWMwNXlHZTl0N0RMTkVlbzJKL3c2NCtNVnpDUkh4MUE2bUhrbHBXYTk2b3RSQld0SE8zMVE4Ui91TWJXYlRUUgpUb3grM09nLzcxcENJRmtGTVlzTHJMSHVpakRsb3c1Ny8rRmE0M3Bka0lGR0ZHeHdzbm1SNW5MWXZpdEMxZ242ClAwWU9qN3BjSzJ3NUlZNWpvR0xkOUtYWVY5RG1aQUxwSlgxQXgzNmZHNDJ3cUNOcldtQUFRT2dDb3lyRHQrU3cKQkZPL1FpOVppMVI3bVFBaU9WSTRvMnQxVDFsUjBzSmlUeWNyc1FJREFRQUJBb0lCQUNFTkhET3JGdGg1a1RpUApJT3dxa2UvVVhSbUl5MHlNNHFFRndXWXBzcmUxa0FPMkFDWjl4YS96ZDZITnNlanNYMEM4NW9PbmtrTk9mUHBrClcxVS94Y3dLM1ZpRElwSnBIZ09VNzg1V2ZWRXZtU3dZdi9Fb1V3eHFHRVMvcnB5Z1drWU5WSC9XeGZGQlg3clMKc0dmeVltbXJvM09DQXEyLzNVVVFiUjcrT09md3kzSHdUdTBRdW5FSnBFbWU2RXdzdWIwZzhTTGp2cEpjSHZTbQpPQlNKSXJyL1RjcFRITjVPc1h1Vm5FTlVqV3BBUmRQT1NrRFZHbWtCbnkyaVZURElST3NGbmV1RUZ1NitXOWpqCmhlb1hNN2czbkE0NmlLenUzR0YwRWhLOFkzWjRmeE42NERkbWNBWnphaU1vMFJVaktWTFVqbVlQSEUxWWZVK3AKMkNYb3dNRUNnWUVBMTgyaU52UEkwVVlWaUh5blhKclNzd1YrcTlTRStvVi90U2ZSUUNGU2xsV0d3KzYyblRiVwpvNXpoL1RDQW9VTVNSbUFPZ0xKWU1LZUZ1SWdvTEoxN1pvWjN0U1czTlVtMmRpT0lPSHorcTQxQzM5MDRrUzM5CjkrYkFtVmtaSFA5VktLOEMraS9tek5mSkdHZEJadGIweWtTM2t3OUIxTHdnT3o3MDhFeXFSQ2tDZ1lFQTBXWlAKbzF2MThnV2tMK2FnUDFvOE13eDRPZlpTN3dKY3E0Z0xnUWhjYS9pSkttY0x0RFN4cUJHckJ4UVo0WTIyazlzdQpzTFVrNEJobGlVM29iUUJNaUdtMGtITHVBSEFRNmJvdWZBMUJwZjN2VFdHSkhSRjRMeFJsNzc2akw4UXI4VnpxClpURVBtY0R0T0hpYjdwb2I1Z2IzSDhiVGhYeUhmdGZxRW55alhFa0NnWUVBdk9DdDZZclZhTlQrWThjMmRFYk4Kd3dJOExBaUZtdjdkRjZFUjlCODJPWDRCeGR0WTJhRDFtNTNqN2NaVnpzNzFYOE1TN25FcDN1dkFqaElkbDI3KwpZbTJ1dUUyYVhIbDN5VTZ3RzBETFpUcnVIU0Z5TVI4ZithbHRTTXBDd0s1NXluSGpHVFp6dXpYaVBBbWpwRzdmCk1XbVRncE1IK3puc3UrNE9VNFBHUW9FQ2dZQWNqdUdKbS84YzlOd0JsR2lDZTJIK2JGTHhSTURteStHcm16QkcKZHNkMENqOWF3eGI3aXJ3MytjRGpoRUJMWExKcjA5YTRUdHdxbStrdElxenlRTG92V0l0QnNBcjVrRThlTVVBcAp0djBmRUZUVXJ0cXVWaldYNWlaSTNpMFBWS2ZSa1NSK2pJUmVLY3V3aWZKcVJpWkw1dU5KT0NxYzUvRHF3Yk93CnRjTHAwUUtCZ0VwdEw1SU10Sk5EQnBXbllmN0F5QVBhc0RWRE9aTEhNUGRpL2dvNitjSmdpUmtMYWt3eUpjV3IKU25QSG1TbFE0aEluNGMrNW1lbHBDWFdJaklLRCtjcTlxT2xmQmRtaWtYb2RVQ2pqWUJjNnVGQ1QrNWRkMWM4RwpiUkJQOUNtWk9GL0hOcHN0MEgxenhNd1crUHk5Q2VnR3hhZ0ZCekxzVW84N0xWR2h0VFFZCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==


```
```
k get secrets -n cert-manager
NAME                                    TYPE                 DATA   AGE
ca-key-pair-k8s-lab                     Opaque               2      29m  >>> secret created
my-cert-manager-webhook-ca              Opaque               3      13m
sh.helm.release.v1.my-cert-manager.v1   helm.sh/release.v1   1      13m
```
deploy the CA issuer which references this `Secret`

```

cat <<EOF > 02-ca-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer-k8s-lab
  namespace: cert-manager
spec:
  ca:
    secretName: ca-key-pair-k8s-lab
EOF
```

Cluster issuer `kind:clusterIssuer`

```
$ kubectl get clusterissuers -n cert-manager
NAME                READY   AGE
ca-issuer-k8s-lab   True    8m43s
```

#### Notes

Issuer can be namespace specific. 

Namespaces issuer `kind:Issuer`

```
$ kubectl get issuers ca-issuer -n sandbox -o wide
NAME          READY   STATUS                AGE
ca-issuer     True    Signing CA verified   2m
```



From the application namespace that is using this certmanager. In this example argocd. ArgoCD has specific configuration to use the cert manager for tls.

```
k get certificates -A
NAMESPACE   NAME            READY   SECRET              AGE
argocd      argocd-server   True    argocd-server-tls   13m
```









Summary.

This example uses a Private CA to generate certs for the domain `k8s.lab`

As `k8s.lab` is not resolvable on the internet, this is a workaround. 

The steps:

1. generate ca key pair.

2. Create secret in the name space `cert-manager`

3. Deploy "kind:ClusterIssuer" in the same namespace. When deploying in a different namespace the secret was not readable by cert-manager.

   

That's all the steps required to create a Private CA issuer.



```


```

