



https://argo-cd.readthedocs.io/en/stable/proposals/config-management-plugin-v2/#summary

steps updated from this portal references



https://medium.com/@raosharadhi11/argocd-with-vault-using-argocd-vault-plugin-dccbc302f0c2



Overview

1. install jsonnet on argocd side car??

   this is done on the main container initialization. 

   ```
   
   2 methods to update
   
   1.
   kubectl -n argocd patch deployments/argocd-repo-server --patch-file plugin-patch.yaml 
   
   2. Helm with multple value files.
    helm upgrade -f ./values.yaml  -f ./plugin-patch.yaml argocd argo/argo-cd --version 6.4.0 -n argocd --reuse-values
   
   
   ```

   

   Following Deployment will deploy the plugin's `jsonnet-helm-with-crds` and `jsonnet-helm` as sidecar to `argocd-repo-server`

   ```
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: argocd-repo-server
     namespace: argocd
   spec:
     template:
       spec:
         initContainers:
           - args:
               - >-
                 wget -qO- 
                 https://github.com/google/jsonnet/releases/download/v0.17.0/jsonnet-bin-v0.17.0-linux.tar.gz 
                 | tar -xvzf -   && mv jsonnet jsonnetfmt /custom-tools/
             command:
               - sh
               - '-c'
             image: alpine:3.8
             name: download-tools
             volumeMounts:
             - mountPath: /custom-tools
               name: custom-tools
         # volumes:
         # - emptyDir: {}
         #   name: custom-tools
   repoServer:
     extraContainers: 
       # add plugin jsonnet-helm-with-crds-plugin.yaml to argocd as side car
       - command:
           - /var/run/argocd/argocd-cmp-server
         image: quay.io/argoproj/argocd:v2.9.0
         name: jsonnet-helm-with-crds
         securityContext:
           runAsNonRoot: true
           runAsUser: 999
         volumeMounts:
           - mountPath: /var/run/argocd
             name: var-files
           - mountPath: /home/argocd/cmp-server/plugins
             name: plugins
             # Register plugins into sidecar
           - mountPath: /home/argocd/cmp-server/config/plugin.yaml
             name: jsonnet-helm-with-crds   # plugin name from configmap
             subPath: plugin.yaml
           - mountPath: /tmp
             name: cmp-tmp
           - mountPath: /usr/bin/jsonnet
             name: custom-tools
             subPath: jsonnet
       - command:
           - /var/run/argocd/argocd-cmp-server
         image: quay.io/argoproj/argocd:v2.9.0
         name: jsonnet-helm
         securityContext:
           runAsNonRoot: true
           runAsUser: 999
         volumeMounts:
           - mountPath: /var/run/argocd
             name: var-files
           - mountPath: /home/argocd/cmp-server/plugins
             name: plugins
           # Register plugins into sidecar
           - mountPath: /home/argocd/cmp-server/config/plugin.yaml
             name: jsonnet-helm    # plugin name from configmap
             subPath: plugin.yaml
           - mountPath: /tmp
             name: cmp-tmp
           # Important: Mount tools into $PATH
           - mountPath: /usr/bin/jsonnet
             name: custom-tools
             subPath: jsonnet
     volumeMounts:
       - mountPath: /usr/local/bin/jsonnet
         name: custom-tools
         subPath: jsonnet
     volumes:
       - emptyDir: {}
         name: custom-tools
       - configMap:
           name: jsonnet-helm-with-crds # from the plugin name created
         name: jsonnet-helm-with-crds
       - configMap:
           name: jsonnet-helm # from the plugin name created
         name: jsonnet-helm
       - emptyDir: {}
         name: cmp-tmp
   
   
   ```

2. Create the config map for the jsonnet-helm and jsonnet-helm-crds

   Working 

   ```
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: jsonnet-helm-with-crds
     namespace: argocd
     annotations:
       app.kubernetes.io/part-of: argocd
   data:
     plugin.yaml: |
       apiVersion: argoproj.io/v1alpha1
       kind: ConfigManagementPlugin
       metadata:
         name: jsonnet-helm-with-crds
       spec:
         version: v1.0
         init:
           command: ["/bin/sh", "-c"]
           args: ["mkdir -p ./templates && jsonnet -m . helm-chart.libsonnet && helm dependency build && [ -f './templates/_templates.jsonnet' ] && jsonnet ./templates/_templates.jsonnet > ./templates/templates.yaml || exit 0"]
         generate:
           command: ["/bin/sh", "-c"]
           args: ["helm template $ARGOCD_APP_NAME . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace $ARGOCD_APP_NAMESPACE --include-crds"]
         discover:
           find:
             command: [sh, -c, 'if [ "$ARGOCD_ENV_PLUGIN" = "jsonnet-helm-with-crds" ]; then echo Hi; fi' ]
   
   ---
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: jsonnet-helm
     namespace: argocd
     annotations:
       app.kubernetes.io/part-of: argocd
   data:
     plugin.yaml: |
       apiVersion: argoproj.io/v1alpha1
       kind: ConfigManagementPlugin
       metadata:
         name: jsonnet-helm
       spec:
         version: v1.0
         init:
           command: ["/bin/sh", "-c"]
           args: ["mkdir -p ./templates && jsonnet -m . helm-chart.libsonnet && helm dependency build && [ -d './templates' ] && jsonnet ./templates/_templates.jsonnet > ./templates/templates.yaml || exit 0"]
         generate:
           command: ["/bin/sh", "-c"]
           args: ["helm template $ARGOCD_APP_NAME . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace $ARGOCD_APP_NAMESPACE"]
         discover:
           find:
             command: [sh, -c, 'if [ "$ARGOCD_ENV_PLUGIN" = "jsonnet-helm" ]; then echo Hi; fi' ]
   
   
   ```


the above code is now working ,  next step is to check if the deployment of the image pull secret using these plugins work. 

updated as of 13 April 2024 



Some notes

`kube,libsonnet` required to be used in the `customizations.libsonnet`.

 

`kube,libsonnet`  contains the Kubernetes specific kind i.e. `ClusterRole, ClusterRoleBinding, ServiceAccount` etc.

 `customizations.libsonnet` will then use these kind in the configuration. Basically you have to build the jsonnet equivalent of the yaml output files. 

1.  using the helm template output, the yaml equivalents are generated.

   ```
   helm template imagepullsecret-patcher ./imagepullsecret-patcher-1.0.0 -f ./imagepullsecret-patcher-1.0.0/values.yaml --namespace imagepullsecret-patcher --create-namespace --set installCRDs=true  --output-dir manifests/helm-manifests
   
   
   ```

   ![image-20240413233730265](C:\Users\suresh\AppData\Roaming\Typora\typora-user-images\image-20240413233730265.png)

2. The jsonnet files don't need to be regenerated from scratch, you can convert the Helm manifests in yaml.

   and then add them to the `customizations.libsonnet`

3. To finalize how the converted files will be part of `customizations.libsonnet`.

   ```
   
   
   
   
   ```
   
   
   
4. 

