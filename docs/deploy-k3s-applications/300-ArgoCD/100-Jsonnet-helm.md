#### Jsonnet-helm



https://github.com/databricks/jsonnet-style-guide

https://brian-candler.medium.com/streamlining-kubernetes-application-deployment-with-jsonnet-711e15e9c665



#### Enable Argocd jsonnet-helm-with-crds

Template from

https://argo-cd.readthedocs.io/en/stable/operator-manual/config-management-plugins/



Sidecar plugin

```
apiVersion: argoproj.io/v1alpha1
kind: ConfigManagementPlugin
metadata:
  name: jsonnet-helm-with-crds-plugin
spec:
  version: v1.0
  # The init command runs in the Application source directory at the beginning of each manifest generation. The init
  # command can output anything. A non-zero status code will fail manifest generation.
  init:
    # Init always happens immediately before generate, but its output is not treated as manifests.
    # This is a good place to, for example, download chart dependencies.
    command: [sh]
    args: [-c, 'echo "Initializing..."']
    args: ["mkdir -p ./templates && jsonnet -m . helm-chart.libsonnet && helm dependency build && [ -f './templates/_templates.jsonnet' ] && jsonnet ./templates/_templates.jsonnet > ./templates/templates.yaml || exit 0"]
  # The generate command runs in the Application source directory each time manifests are generated. Standard output
  # must be ONLY valid Kubernetes Objects in either YAML or JSON. A non-zero exit code will fail manifest generation.
  # To write log messages from the command, write them to stderr, it will always be displayed.
  # Error output will be sent to the UI, so avoid printing sensitive information (such as secrets).
  generate:
    command: [sh, -c]
    args:
      - |
        echo "{\"kind\": \"ConfigMap\", \"apiVersion\": \"v1\", \"metadata\": { \"name\": \"$ARGOCD_APP_NAME\", \"namespace\": \"$ARGOCD_APP_NAMESPACE\", \"annotations\": {\"Foo\": \"$ARGOCD_ENV_FOO\", \"KubeVersion\": \"$KUBE_VERSION\", \"KubeApiVersion\": \"$KUBE_API_VERSIONS\",\"Bar\": \"baz\"}}}"
  # The discovery config is applied to a repository. If every configured discovery tool matches, then the plugin may be
  # used to generate manifests for Applications using the repository. If the discovery config is omitted then the plugin 
  # will not match any application but can still be invoked explicitly by specifying the plugin name in the app spec. 
  # Only one of fileName, find.glob, or find.command should be specified. If multiple are specified then only the 
  # first (in that order) is evaluated.
  discover:
    # fileName is a glob pattern (https://pkg.go.dev/path/filepath#Glob) that is applied to the Application's source 
    # directory. If there is a match, this plugin may be used for the Application.
    fileName: "./subdir/s*.yaml"
    find:
      # This does the same thing as fileName, but it supports double-start (nested directory) glob patterns.
      glob: "**/Chart.yaml"
      # The find command runs in the repository's root directory. To match, it must exit with status code 0 _and_ 
      # produce non-empty output to standard out.
      command: [sh, -c, find . -name env.yaml]
  # The parameters config describes what parameters the UI should display for an Application. It is up to the user to
  # actually set parameters in the Application manifest (in spec.source.plugin.parameters). The announcements _only_
  # inform the "Parameters" tab in the App Details page of the UI.
  parameters:
    # Static parameter announcements are sent to the UI for _all_ Applications handled by this plugin.
    # Think of the `string`, `array`, and `map` values set here as "defaults". It is up to the plugin author to make 
    # sure that these default values actually reflect the plugin's behavior if the user doesn't explicitly set different
    # values for those parameters.
    static:
      - name: string-param
        title: Description of the string param
        tooltip: Tooltip shown when the user hovers the
        # If this field is set, the UI will indicate to the user that they must set the value.
        required: false
        # itemType tells the UI how to present the parameter's value (or, for arrays and maps, values). Default is
        # "string". Examples of other types which may be supported in the future are "boolean" or "number".
        # Even if the itemType is not "string", the parameter value from the Application spec will be sent to the plugin
        # as a string. It's up to the plugin to do the appropriate conversion.
        itemType: ""
        # collectionType describes what type of value this parameter accepts (string, array, or map) and allows the UI
        # to present a form to match that type. Default is "string". This field must be present for non-string types.
        # It will not be inferred from the presence of an `array` or `map` field.
        collectionType: ""
        # This field communicates the parameter's default value to the UI. Setting this field is optional.
        string: default-string-value
      # All the fields above besides "string" apply to both the array and map type parameter announcements.
      - name: array-param
        # This field communicates the parameter's default value to the UI. Setting this field is optional.
        array: [default, items]
        collectionType: array
      - name: map-param
        # This field communicates the parameter's default value to the UI. Setting this field is optional.
        map:
          some: value
        collectionType: map
    # Dynamic parameter announcements are announcements specific to an Application handled by this plugin. For example,
    # the values for a Helm chart's values.yaml file could be sent as parameter announcements.
    dynamic:
      # The command is run in an Application's source directory. Standard output must be JSON matching the schema of the
      # static parameter announcements list.
      command: [echo, '[{"name": "example-param", "string": "default-string-value"}]']

  # If set to `true` then the plugin receives repository files with original file mode. Dangerous since the repository
  # might have executable files. Set to true only if you trust the CMP plugin authors.
  preserveFileMode: false

```





Register Plugin sidecar

```
containers:
- name: jsonnet-helm-with-crds
  command: [/var/run/argocd/argocd-cmp-server] # Entrypoint should be Argo CD lightweight CMP server i.e. argocd-cmp-server
  image: quay.io/argoproj/argocd:v2.9.0 # This can be off-the-shelf or custom-built image
  securityContext:
    runAsNonRoot: true
    runAsUser: 999
  volumeMounts:
    - mountPath: /var/run/argocd
      name: var-files
    - mountPath: /home/argocd/cmp-server/plugins
      name: plugins
    # Remove this volumeMount if you've chosen to bake the config file into the sidecar image.
    - mountPath: /home/argocd/cmp-server/config/plugin.yaml
      subPath: plugin.yaml
      name: jsonnet-helm-with-crds-config
    - name: 'custome-tools'
      mountPath: '/usr/bin/jsonnet'
      subPath: 'jsonnet'
    # Starting with v2.4, do NOT mount the same tmp volume as the repo-server container. The filesystem separation helps 
    # mitigate path traversal attacks.
    - mountPath: /tmp
      name: cmp-tmp
volumes:
- configMap:
    name: jsonnet-helm-with-crds-config
  name: jsonnet-helm-with-crds-config
- emptyDir: {}
  name: cmp-tmp


```



#### apply manually via Helm to validate

```

helm upgrade -f ./argo-cd-6.4.0/values.yaml  argocd argo/argo-cd --version 6.4.0 -n argocd --reuse-values 

helm uninstall argocd -n argocd
```





#### Convert yaml to jsonnet

```

# Convert values.yaml to json
yq -o json $FOLDER_NAME/values.yaml > $FOLDER_NAME/values-temp.libsonnet

# Run jsonnetfmt on the file

jsonnetfmt $FOLDER_NAME/values-temp.libsonnet > $FOLDER_NAME/values.libsonnet

rm $FOLDER_NAME/values-temp.libsonnet


```



Deploy imagepullsecret-patcher

```

helm repo add empathyco https://empathyco.github.io/helm-charts/

helm repo update

helm pull  empathyco/imagepullsecret-patcher --version 1.0.0

mkdir imagepullsecret-patcher-1.0.0

tar -xvf imagepullsecret-patcher-1.0.0.tgz --strip-components=1 -C \imagepullsecret-patc
```

Files created imagepullsecrets

```
libs/imagepullsecret-patcher-1.0.0/
parameters.json
chart.libsonnet  ( to create from template not converted from Chart.yaml)
values.libsonnet (converter from default from helm values.yaml)
customizations.libsonnet ( any specific changes are peformed here.)


```



Add to ArgoCD app of apps

```

cat << EOF > app-of-apps/templates/imagepullsecret-patcher.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: imagepullsecret-patcher
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: clusters/ctx-k3s-cluster-77/imagepullsecret-patcher
    targetRevision: HEAD
    
    helm:
      valueFiles:
      - values.yaml
      values: |
        pushgateway:
          enabled: false
      releaseName: imagepullsecret-patcher
      parameters:
      - name: app
        value: imagepullsecret-patcher
  destination:
    server: https://kubernetes.default.svc
    namespace: prometheus
  syncPolicy:
    #automated:
      #selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

```







###################

Files created

```
libs/imagepullsecret-patcher-1.0.0/
parameters.json
chart.libsonnet
values.libsonnet
customizations.libsonnet (imports globals.libsonnet,kube.libsonnet,kubeExtensions.libsonnet)


#####
libs/
globals.libsonnet ( common configs i.e. argocd to access repo PAT tokens,global cluster prd/dev sites., azure subscription ID's, import thanos endpoints)
kube.libsonnet (https://github.com/kube-libsonnet/kube-libsonnet)
kubeExtensions.libsonnet ( helper.libsonnet , kube.libsonnet, + some customization)
helper.libsonnet
kube.libsonnet ** duplicated
servicePrincipals.json ( factory Service principals)
storageClassLogic.libsonnet ( select stroge class based on kubernetes type)
clustermanagement.libsonnet ( argcd.libsonnet,globals.libsonnet,kube.libsonnet)
argocd.libsonnet ( globals.libsonnet, kube.libsonnet + customizations)
argocd-projects.libsonnet ( where arogcd project specific configurations are setup )

#####


```

