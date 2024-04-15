Install prerequisites on `alpine1`

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

