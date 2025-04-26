## add helm-jsonnet plugin

<argocd-values.yaml>

to check if working

```
configs:
  cm:
    configManagementPlugins: |
      - name: jsonnet-helm-with-crds
        generate:
          command: ["/bin/sh", "-c"]
          args: ["helm template $ARGOCD_APP_NAME . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace $ARGOCD_APP_NAMESPACE --include-crds"]
      - name: jsonnet-helm
        generate:
          command: ["/bin/sh", "-c"]
          args: ["helm template $ARGOCD_APP_NAME . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace $ARGOCD_APP_NAMESPACE"]


```





not working

```
configs:
  cm:
    configManagementPlugins: |

   - name: jsonnet-helm-with-crds
     generate:
       command: ["/bin/sh", "-c"]
       args: ["helm template $ARGOCD_APP_NAME . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace $ARGOCD_APP_NAMESPACE --include-crds"]
        - name: jsonnet-helm
          generate:
            command: ["/bin/sh", "-c"]
            args: ["helm template $ARGOCD_APP_NAME . --api-versions monitoring.coreos.com/v1 --api-versions networking.k8s.io/v1/Ingress --namespace $ARGOCD_APP_NAMESPACE"]

controller:
  extraContainers:

   - name: jsonnet-helm-with-crds
     image: quay.io/argoproj/argocd:v2.9.0
     command: ["/var/run/argocd/argocd-cmp-server"]
     securityContext:
       runAsNonRoot: true
       runAsUser: 999
     volumeMounts:
       - mountPath: "/var/run/argocd"
         name: var-files
       - mountPath: "/home/argocd/cmp-server/plugins"
         name: plugins
       - mountPath: "/home/argocd/cmp-server/config/plugin.yaml"
         name: jsonnet-helm-with-crds
         subPath: "plugin.yaml"
       - mountPath: "/tmp"
         name: cmp-tmp
       - mountPath: "/usr/bin/jsonnet"
         name: custom-tools
         subPath: "jsonnet"

```



    - name: jsonnet-helm
      image: quay.io/argoproj/argocd:v2.9.0
      command: ["/var/run/argocd/argocd-cmp-server"]
      securityContext:
        runAsNonRoot: true
        runAsUser: 999
      volumeMounts:
        - mountPath: "/var/run/argocd"
          name: var-files
        - mountPath: "/home/argocd/cmp-server/plugins"
          name: plugins
        - mountPath: "/home/argocd/cmp-server/config/plugin.yaml"
          name: jsonnet-helm
          subPath: "plugin.yaml"
        - mountPath: "/tmp"
          name: cmp-tmp
        - mountPath: "/usr/bin/jsonnet"
          name: custom-tools
          subPath: "jsonnet"
