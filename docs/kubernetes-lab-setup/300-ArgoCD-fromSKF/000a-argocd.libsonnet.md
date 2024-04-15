```
local globals = import 'globals.libsonnet';
local kube = import 'kube.libsonnet';

{
  Application(name, namespace='default'): kube._Object('argoproj.io/v1alpha1', 'Application', name) {
    local this = self,
    spec: {
      project: name,
      destination: {
        namespace: namespace,
        //server: error 'Spec/Destination/server must be set.',
      },
      source: {
        path: error 'Spec/Source/path must be set.',
        repoURL: error 'Spec/Source/repoURL must be set.',
        targetRevision: 'HEAD',
      },
    },
  },

  AppProject(name, role, server='*', namespace='*'): kube._Object('argoproj.io/v1alpha1', 'AppProject', name) {
    local this = self,
    spec: {
      clusterResourceWhitelist: [
        {
          group: '*',
          kind: '*',
        },
      ],
      description: name,
      destinations: [{
        server: server,
        namespace: namespace,
      }],
      roles: [
        role,
      ],
      sourceRepos: [
        '*',
      ],
    },
  },

  AppOfAppsProject(name): kube._Object('argoproj.io/v1alpha1', 'AppProject', name) {
    local this = self,
    spec: {
      namespaceResourceBlacklist: [
        {
          group: 'bitnami.com',
          kind: 'SealedSecret',
        },
        {
          group: '*',
          kind: 'Secret',
        },
      ],
      clusterResourceWhitelist: [
        {
          group: 'argoproj.io',
          kind: 'Application',
        },
        {
          group: 'argoproj.io',
          kind: 'AppProject',
        },
      ],
      destinations: [
        {
          namespace: 'argocd',
          server: globals.clusters.argocd,
        },
      ],
      orphanedResources: {
        warn: true,
      },
      sourceRepos: [
        globals.gitrepossshkey.kubeApplicationsState,
      ],
      description: name,
    },
  },
}



```

