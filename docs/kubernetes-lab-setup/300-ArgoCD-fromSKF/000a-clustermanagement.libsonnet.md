```

local argocd = import 'argocd.libsonnet';
local globals = import 'globals.libsonnet';
local kube = import 'kube.libsonnet';


local getApplicationPath(cluster, name) =
  if std.objectHas(cluster, 'environment')
  then 'clusters/' + cluster.region + '/' + cluster.countryFactory + '/' + cluster.environment + '/' + cluster.name + '/' + name else
    if std.objectHas(cluster, 'region')
    then 'clusters/' + cluster.region + '/' + cluster.countryFactory + '/' + cluster.name + '/' + name
    else 'clusters/' + cluster.name + '/' + name;

local getApplicationPathCMS(cluster) = if cluster.environment == 'dev' then 'cms-host/' + cluster.countryFactory + '/' + cluster.environment
else if cluster.environment == 'prd' then 'cms-host/' + cluster.countryFactory + '/' + cluster.environment + '/' + cluster.name
else '';

local isPlatformApplications(name, namespace) =
  local platformNamespaces = [
    'argo-events',
    'imagepullsecret-patcher',
    'longhorn-system',
    'metallb-system',
    'misc',
    'rbac',
    'ads',
    'dxc-nsmanager',
  ];
  std.member(platformNamespaces, namespace);

{

  //Designed for use in the cluster app
  //ArgoCD Application meant to hold other applications for each individual app. One per destination cluster.
  ClusterApp(cluster):: argocd.Application(cluster.name) {
    metadata+: {
      namespace: 'argocd',
    },
    spec+: {
      destination+: {
        server: 'https://kubernetes.default.svc',
        namespace: 'argocd',
      },
      project: 'default',  //cluster.name,
      source: {
        path: 'clusters/' + cluster.region + '/' + cluster.countryFactory + '/' + cluster.environment + cluster.name,
        repoURL: globals.gitrepossshkey.kubeApplicationsState,
        targetRevision: 'HEAD',
      },
      // syncPolicy: {
      //   automated: {},
      // },
    },
  },

  ClusterAppWithAutoSync(cluster):: $.ClusterApp(cluster) {
    spec+: {
      syncPolicy: {
        automated: {},
      },
    },
  },

  BaseClusterApp(cluster):: argocd.Application(cluster.name + '-cluster-app') {
    metadata+: {
      namespace: 'argocd',
    },
    spec+: {
      destination+: {
        name: 'in-cluster',
        namespace: 'argocd',
      },
      project: 'default',  //cluster.name,
      source: {
        path: 'clusters/' + cluster.region + '/' + cluster.countryFactory + '/' + cluster.environment + '/' + cluster.name,
        repoURL: 'git@ssh.dev.azure.com:v3/skf-digital-manufacturing/SKF-DP-WCM%20Infrastructure/k8s-cluster-configuration',
        targetRevision: 'HEAD',
      },
      syncPolicy: {
        automated: {},
      },
    },
  },

  ClusterAppProject(cluster):: argocd.AppProject(cluster.name, cluster.uri) {
    metadata+: {
      namespace: 'argocd',
    },
    spec+: {
      sourceRepos: [
        globals.gitrepossshkey.kubeApplicationsState,
      ],
      destinations: std.flattenArrays(
        [
          [
            {
              server: 'https://kubernetes.default.svc',
              namespace: 'argocd',
            },
          ],
          [
            {
              server: cluster.uri,
              namespace: ns,
            }
            for ns in globals.clusterAppNamespaces
          ],
        ],
      ),
    },
  },

  //This is the normal yaml/jsonnet directory cluster application
  App(cluster, name, namespace):: argocd.Application(cluster.name + '-' + name) {
    spec+: {
      destination+: {
        name: cluster.nickname,
        //server: cluster.uri,
        namespace: namespace,
      },
      project: if isPlatformApplications(name, namespace) then 'platform' else 'default',
      source: {
        path: getApplicationPath(cluster, name),
        repoURL: globals.gitrepossshkey.kubeApplicationsState,
        targetRevision: 'HEAD',
      },
      syncPolicy: {
        syncOptions: [
          'CreateNamespace=true',
        ],
      },
    },
  },

  //This is the normal yaml/jsonnet directory cluster application but with AutoSync
  AppWithAutoSync(cluster, name, namespace):: argocd.Application(cluster.name + '-' + name) {
    spec+: {
      destination+: {
        name: cluster.nickname,
        //server: cluster.uri,
        namespace: namespace,
      },
      project: if isPlatformApplications(name, namespace) then 'platform' else 'default',
      source: {
        path: getApplicationPath(cluster, name),
        repoURL: globals.gitrepossshkey.kubeApplicationsState,
        targetRevision: 'HEAD',
      },
      syncPolicy: {
        automated: {
          prune: true,
          selfHeal: true,
        },
        syncOptions: [
          'CreateNamespace=true',
        ],
      },
    },
  },

  CMSApp(cluster):: argocd.Application(cluster.name + '-' + 'cms-app') {
    spec+: {
      destination+: {
        name: cluster.nickname,
        //server: cluster.uri,
        namespace: 'cms',
      },
      project: 'cms',  //cluster.name,
      source: {
        path: getApplicationPathCMS(cluster),
        repoURL: 'git@ssh.dev.azure.com:v3/skf-digital-manufacturing/CMS/cms-k8s-configuration',
        targetRevision: 'HEAD',
      },
      syncPolicy: {
        automated: {},
        syncOptions: [
          'CreateNamespace=true',
        ],
      },
    },
  },

  // Do not use this method directly from outside.
  local BFCApp(cluster, name, namespace) = argocd.Application(cluster.name + '-' + name) {
    spec+: {
      destination+: {
        name: cluster.nickname,
        namespace: 'bfc',
      },
      project: 'bfc',  //cluster.name,
      source: {
        repoURL: 'git@ssh.dev.azure.com:v3/skf-digital-manufacturing/SKF-DP-WCM%20Infrastructure/k8s-cluster-configuration',
        targetRevision: 'HEAD',
      },
      syncPolicy: {
        syncOptions: [
          'CreateNamespace=true',
          'ApplyOutOfSyncOnly=true',
        ],
      },
    },
  },

  BFCAppV3(cluster, name, namespace, iteration):: BFCApp(cluster, name, namespace) {
    spec+: {
      source+: {
        path: std.join('/', ['applications', 'bfc', cluster.region, cluster.countryFactory, cluster.environment, iteration]),
      },
    },
  },

  BFCAppV4(cluster, name, namespace, iteration):: BFCApp(cluster, name, namespace) {
    spec+: {
      source+: {
        path: std.join('/', ['applications', 'bfc', cluster.region, cluster.countryFactory, cluster.environment, iteration]),
      },
      syncPolicy+: {
        automated: {},
      },
    },
  },

  //Use a custom Config Management Plugin - https://argoproj.github.io/argo-cd/user-guide/config-management-plugins/
  JsonnetHelmApplication(cluster, name, namespace):: $.App(cluster, name, namespace) {
    spec+: {
      project: if isPlatformApplications(name, namespace) then 'platform' else 'default',
      source+: {
        plugin: {
          env: [
            {
              name: 'PLUGIN',
              value: 'jsonnet-helm',
            },
          ],
        },
      },
    },
  },

  //Use a custom Config Management Plugin - https://argoproj.github.io/argo-cd/user-guide/config-management-plugins/
  JsonnetHelmApplicationWithCrds(cluster, name, namespace):: $.App(cluster, name, namespace) {
    spec+: {
      project: if isPlatformApplications(name, namespace) then 'platform' else 'default',
      source+: {
        plugin: {
          env: [
            {
              name: 'PLUGIN',
              value: 'jsonnet-helm-with-crds',
            },
          ],
        },
      },
    },
  },

  JsonnetHelmApplicationWithCrdsAutosync(cluster, name, namespace):: $.App(cluster, name, namespace) {
    spec+: {
      source+: {
        plugin: {
          env: [
            {
              name: 'PLUGIN',
              value: 'jsonnet-helm-with-crds',
            },
          ],
        },
      },
      syncPolicy: {
        automated: {},
        syncOptions: [
          'CreateNamespace=true',
        ],
      },
    },
  },

  JsonnetHelmApplicationCustomProj(cluster, name, namespace, project):: $.App(cluster, name, namespace) {
    spec+: {
      project: project,
      source+: {
        plugin: {
          env: [
            {
              name: 'PLUGIN',
              value: 'jsonnet-helm',
            },
          ],
        },
      },
    },
  },
}


```

