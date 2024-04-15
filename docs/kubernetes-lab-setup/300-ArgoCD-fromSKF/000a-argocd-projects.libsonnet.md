```

//# This is where we manage our ArgoCD projects globally.
//# Reason for moving this configuration from libs/argocd-version
//# was that we want to add them to all versions, always

// To test run this, just 'jsonnet argocd-projects.libsonnet'

// What do we need to when new project ProjectX is added?

local kube = import 'kube.libsonnet';

local allResources = [
  {
    group: '*',
    kind: '*',
  },
];

// This will provide a default admin role for the project with proper naming.
// This will give a group in Azure with name-admin the admin rights to the entire project.
local defaultAdminRole(name, description=null) = {
  description: if description == null then name + ' Administrator' else description,
  groups: [
    name + '-admins',
  ],
  name: 'admin',
  policies: [
    'p, proj:' + name + ':admin, applications, *, ' + name + '/*, allow',
  ],
};

local defaultProjectTemplate(name, long_name=null) = kube._Object('argoproj.io/v1alpha1', 'AppProject', name) {
  spec+: {
    description: name,
    clusterResourceWhitelist: allResources,
    destinations: [],  //Must be provided as overrides.
    roles: [
      defaultAdminRole(name, long_name),
    ],  //Can be overriden with more roles.
    sourceRepos: [],  //Must be provided as overrides.
  },
};

{
  Get: function(p) [
    defaultProjectTemplate('platform') {
      spec+: {
        destinations: [
          {
            namespace: '*',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'Platform Administrator',
            groups: [
              'platform-admin',
            ],
            name: 'admin',
            policies: [
              'p, proj:platform:admin, applications, *, platform/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
        syncWindows: if std.substr(p.uri, 7, 3) == 'prd' then [
          {
            kind: 'allow',
            schedule: '0 18 * * 6',
            duration: '16h',
            manualSync: true,
            applications: [
              '*-nginx',
              '*-velero',
              '*-external-dns',
              '*-argo-events',
              '*-argo-rollouts',
              '*-cert-manager',
              '*-eck-operator',
              '*-external-secrets-operator',
              '*-filebeat',
              '*-grafana-dashboards',
              '*-grafana-operator',
              '*-kube-eagle',
              '*-misc',
              '*-nginx',
              '*-prometheus',
              '*-prometheus-crds',
              '*-prometheus-rules',
              '*-sealed-secrets',
              '*-velero',
              '*-metallb',
              '*-longhorn',
              '*-thanos',
              '*-fluent-bit',
              '*-argocd'
            ],
            // Right now timezone is passed here from params.libsonnet on site argocd. e.g: C:\Users\darshad3\git\skf\k8s-cluster-configuration\argocd\fr-21n-dev-01-aks\params.libsonnet
            // To Do: check for possibilities to centralized the timezone info somewhere in libs
            timeZone: p.timeZone,
          },
        ] else [],
      },
    },
    defaultProjectTemplate('data-products') {
      spec+: {
        destinations: [
          {
            namespace: '*',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'Data Products Administrator',
            groups: [
              'data-products-admin',
            ],
            name: 'admin',
            policies: [
              'p, proj:data-products:admins, applications, *, data-products/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },

    },
    defaultProjectTemplate('cms') {
      spec+: {
        description: 'CMS application',
        destinations: [
          {
            namespace: 'cms',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'CMS Administrator',
            groups: [
              'cms-admin',
            ],
            name: 'admin',
            policies: [
              'p, proj:cms:admin, applications, *, cms/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
    defaultProjectTemplate('wcm-iiot') {
      spec+: {
        description: 'WCM IIOT Applications',
        destinations: [
          {
            namespace: 'iiot-platform-qa',
            server: '*',
          },
          {
            namespace: 'iiot-platform-uat',
            server: '*',
          },
          {
            namespace: 'iiot-platform-integration',
            server: '*',
          },
          {
            namespace: 'iiot-platform',
            server: '*',
          },
          {
            namespace: 'iiot-platform-dev',
            server: '*',
          },
          {
            namespace: 'aphrodite-qa',
            server: '*',
          },
          {
            namespace: 'aphrodite-uat',
            server: '*',
          },
          {
            namespace: 'aphrodite',
            server: '*',
          },
          {
            namespace: 'aphrodite-dev',
            server: '*',
          },
          {
            namespace: 'velero',
            server: '*',
          },
          {
            namespace: 'grafana-operator',
            server: '*',
          },
          {
            namespace: 'argocd',
            server: 'https://kubernetes.default.svc',
          },
          {
            namespace: 'argocd',
            server: 'in-cluster',
          },
          {
            namespace: 'iiot-global-factory-platform',
            server: '*',
          },
          {
            namespace: 'iiot-global-factory-platform-dev',
            server: '*',
          },
          {
            namespace: 'iiot-global-factory-platform-qa',
            server: '*',
          },
          {
            namespace: 'global-factory-platform',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'WCM IIOT Administrator',
            groups: [
              'wcm-iiot-admin',
            ],
            name: 'admin',
            policies: [
              'p, proj:wcm-iiot:admin, applications, *, wcm-iiot/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
    defaultProjectTemplate('bfc') {
      spec+: {
        description: 'BFC Application',
        destinations: [
          {
            namespace: 'bfc',
            server: '*',
          },
          {
            namespace: 'monitoring',
            server: '*',
          },
          {
            namespace: 'grafana-operator',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'BFC Administrator',
            groups: [
              'platform-admin',
              'application-support-admin'
            ],
            name: 'admin',
            policies: [
              'p, proj:bfc:admin, applications, *, platform/*, allow',
              'p, proj:bfc:admin, applications, *, bfc/*, allow'
            ],
          },
        ],
        sourceRepos: [
          'git@ssh.dev.azure.com:v3/skf-digital-manufacturing/SKF-DP-WCM%20Infrastructure/k8s-cluster-configuration',
        ],
      },
    },
    defaultProjectTemplate('d2w') {
      spec+: {
        description: 'Digital2Win application project',
        destinations: [
          {
            namespace: 'd2w',
            server: '*',
          },
          {
            namespace: 'd2wpgadmin',
            server: '*',
          },
          {
            namespace: 'd2wpgadmin-test',
            server: '*',
          },
          {
            namespace: 'd2wpgadmin-dev',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'D2W Admins',
            groups: [
              'd2w-admins',
            ],
            name: 'd2w-admin',
            policies: [
              'p, proj:d2w:d2w-admin, applications, *, d2w/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },

    //# Todo: Restrict mes namespaces. How do we handle their dynamic namespaces?
    defaultProjectTemplate('mes') {
      spec+: {
        destinations: [
          {
            namespace: '*',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'MES Administrators',
            groups: [
              'mes-admins',
            ],
            name: 'mes-admin',
            policies: [
              'p, proj:mes:mes-admin, applications, *, mes/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
    defaultProjectTemplate('art3mis') {
      spec+: {
        destinations: [
          {
            namespace: 'art3mis',
            server: '*',
          },
          {
            namespace: 'art3mis-stage',
            server: '*',
          },
          {
            namespace: 'art3mis-uat',
            server: '*',
          },
          {
            namespace: 'art3mis-sup',
            server: '*',
          },
          {
            namespace: 'art3mis-sup-stage',
            server: '*',
          },
          {
            namespace: 'art3mis-low',
            server: '*',
          },
          {
            namespace: 'art3mis-low-stage',
            server: '*',
          },
          {
            namespace: 'art3mis-reman',
            server: '*',
          },
          {
            namespace: 'art3mis-reman-stage',
            server: '*',
          },
          {
            namespace: 'argocd',
            server: 'https://kubernetes.default.svc',
          },
        ],
        roles: [
          {
            description: 'art3mis App Administrator',
            groups: [
              'art3mis-admin',
            ],
            name: 'admin',
            policies: [
              'p, proj:art3mis:admin, applications, *, art3mis/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
    defaultProjectTemplate('data-platform') {
      spec+: {
        destinations: [
          {
            namespace: 'spark-apps',
            server: '*',
          },
          {
            namespace: 'spark-operator',
            server: '*',
          },
        ],
        roles: [
          {
            description: 'data-platform App Administrator',
            groups: [
              'data-platform-admins',
            ],
            name: 'admin',
            policies: [
              'p, proj:data-platform:admin, applications, *, data-platform/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
    defaultProjectTemplate('siemens-fmh') {
      spec+: {
        destinations: [
          {
            namespace: 'fmh',
            server: '*',
          },
          {
            namespace: 'loc-int',
            server: '*',
          },
        ],
        roles: [
          defaultAdminRole('siemens-fmh', 'Siemens FMH App Administrator'),
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
    defaultProjectTemplate('visualization') {
      spec+: {
        destinations: [
          {
            namespace: 'kdr',
            server: '*',
          },
          {
            namespace: 'openai-app',
            server: '*',
          },
          {
            name: '*',
            namespace: 'skf-copilot',
            server: '*',
          },
          {
            name: '*',
            namespace: 'argocd',
            server: '*',
          },
        ],
        roles: [
          defaultAdminRole('visualization', 'Visualization App Administrator'),
          {
            description: 'Visualization App Administrator',
            groups: [
              'visualization-admin',
            ],
            name: 'visualization-admin',
            policies: [
              'p, proj:visualization:visualization-admin, applications, *, */*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
    defaultProjectTemplate('railtrace') {
      spec+: {
        destinations: [
          {
            namespace: 'railtrace',
            server: '*',
          },
          {
            namespace: 'railtrace-stage',
            server: '*',
          },
          {
            namespace: 'argocd',
            server: 'https://kubernetes.default.svc',
          },
        ],
        roles: [
          {
            description: 'art3mis-railtrace App Administrator',
            groups: [
              'art3mis-admin',
            ],
            name: 'admin',
            policies: [
              'p, proj:railtrace:admin, applications, *, railtrace/*, allow',
            ],
          },
        ],
        sourceRepos: [
          '*',
        ],
      },
    },
  ],
}

```

