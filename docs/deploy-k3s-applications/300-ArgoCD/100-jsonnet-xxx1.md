

```

3. Generate Helm output in yaml to compare with jsonnet output

helm install <chart-name> <chart-path> --dry-run --debug > temp.yaml

```



```
helm repo add empathyco https://empathyco.github.io/helm-charts/

#helm install my-imagepullsecret-patcher empathyco/imagepullsecret-patcher --version 1.0.0


helm repo update

helm pull  empathyco/imagepullsecret-patcher --version 1.0.0

mkdir imagepullsecret-patcher-1.0.0
tar -xvf imagepullsecret-patcher-1.0.0.tgz --strip-components=1 -C \imagepullsecret-patcher-1.0.0


helm install my-imagepullsecret-patcher imagepullsecret-patcher-1.0.0 --version 1.0.0 --dry-run --debug > temp.yaml


## Generates helm output in yaml , cannot be used in k apply -f 
helm install imagepullsecret-patcher ./imagepullsecret-patcher-1.0.0 -f ./imagepullsecret-patcher-1.0.0/values.yaml --namespace imagepullsecret-patcher --create-namespace --set installCRDs=true --dry-run --debug > imagepullsecret-patcherfromhelm.yaml

helmfile template --quiet --namespace $ARGOCD_APP_NAMESPACE

## Generates the individual Yaml files for each service.

helm template vault hashicorp/vault --output-dir vault-manifests/helm-manifests
helm template imagepullsecret-patcher ./imagepullsecret-patcher-1.0.0 -f ./imagepullsecret-patcher-1.0.0/values.yaml --namespace imagepullsecret-patcher --create-namespace --set installCRDs=true  --output-dir manifests/helm-manifests

```



To finalize how the converted files will be part of `customizations.libsonnet`.

1. From the generated helm yaml files , convert to jsonnet format 

```
convert yaml to jsonnet

# Convert values.yaml to json

yq -o json $FOLDER_NAME/values.yaml > $FOLDER_NAME/values-temp.libsonnet

#Run jsonnetfmt on the file

jsonnetfmt $FOLDER_NAME/values-temp.libsonnet > $FOLDER_NAME/values.libsonnet
################
convert yaml to jsonnet

# Convert values.yaml to json

yq -o json *.yaml > *-temp.libsonnet

#Run jsonnetfmt on the file

jsonnetfmt *-temp.libsonnet > *.libsonnet



```



Updating the  `` with the `rbac.yaml` converted to libsonnet provides the output expected.

But there is a header observed in the output.

![image-20240414010640679](C:\Users\suresh\AppData\Roaming\Typora\typora-user-images\image-20240414010640679.png)

The above is for not helm chart references!!! 



For jsonnet-helm charts the `customizations.libsonnet` are loaded with the parameters that exist in `values.yaml/libsonet`.

 
