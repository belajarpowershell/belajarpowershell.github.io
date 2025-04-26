To use jsonnet helm, the first step is to convert helm charts to  jsonnet-helm format.

This involves downloading the helm chart and performing some conversions. 

# Part 1 Download and extract the helm chart



Helm chart 

```
https://argoproj.github.io/argo-helm

```

Add repo to helm

```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

Download and extract 

```
helm pull  argo/argo-cd --version 4.10.0

chart="argo/argo-cd"; version="4.10.0"; \
name=$(basename "$chart"); \
folder="${name}-${version}"; \
mkdir -p "$folder" && \
helm pull "$chart" --version "$version" -d /tmp && \
tar -xzf /tmp/${name}-${version}.tgz -C "$folder" --strip-components=1


```



# Part 3 Convert helm to jsonnet the process.



Tools required

- yq install from `https://mikefarah.gitbook.io/yq/v/v3.x`
- jsonnet install from ``

Using bash

Convert and format `values.yaml' to jsonnet format

```
yq -o json values.yaml | jsonnetfmt > values.libsonnet
```



# Part 4 

```
chart.libsonnet 
-get from templates folder no changes required

Chart.yaml 
-this file is extracted from helm tar file. Contains all information to deploy the helm

values.libsonnet 
-created by the commands
	(yq -o json values.yaml | jsonnetfmt > values.libsonnet)

values.yaml 
-this file is extracted from helm tar file. Contains all default values used in deployment

parameters.json 
-create this file from template and fill in the location of the helm repository
The appname (this name will be part of the folder name)
The version (this version will complete the folder name)
```

