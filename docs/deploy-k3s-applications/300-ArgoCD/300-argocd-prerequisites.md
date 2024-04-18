#### Install prerequisites on `alpine1`

For the subsequent tasks, there are additional tools required required on `alpine1` .

Install curl

```
apk update 
apk search curl
apk add curl 
```

Install yq and jq

```
apk add yq
apk add jq
```

Install jsonnet

```
apk add jsonnet
```

Install helm

```
apk add helm
```

```
# Convert values.yaml to json

yq -o json $FOLDER_NAME/values.yaml > $FOLDER_NAME/values-temp.libsonnet

#Run jsonnetfmt on the file

jsonnetfmt $FOLDER_NAME/values-temp.libsonnet > $FOLDER_NAME/values.libsonnet

```



#### Folder structure 

The directory structure is important to understand, as the code references require detailed knowledge. Its not complex but important to undestand.



```

k3s-repository/  					## the root folder
change to argocd >-app-of-apps/			## Applications to be deployed by ArgoCD stored here
			-clusters/					## store cluster specific code
					-ctx-k3s-cluster-77
            		-clusterName1
            		-clusterName2
			-libs/						## Common libs folder. All application codes are stored here
										## and referenced by the code in the cluster specific code.


```



For the first few applications, the codes are stored directly in the cluster folder. Once the core applications are set up the code can then be moved to the common libs folder.
