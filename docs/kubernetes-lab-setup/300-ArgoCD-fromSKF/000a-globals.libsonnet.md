```
{
  tenantID: '41875f2b-33e8-4670-92a8-f643afbb243a',

  ads+: {
    november: 'asd',
    databases: import '../clusters/ads-endpoints.json',
  },

  argocd: {
    encryptedData: {
      'admin.password': '',
      'oidc.azure.clientSecret': '',
      'accounts.hybrid-cloud-portal.password': '',
      'accounts.hybrid-cloud-portal.passwordMtime': '',
      'accounts.hybrid-cloud-portal.tokens': '',
      'accounts.hybrid-cloud-github-runner.password': '',
      'accounts.hybrid-cloud-github-runner.passwordMtime': '',
      'accounts.hybrid-cloud-github-runner.tokens': '',
    },

    //# PAT token created by Mats, will be expired on 13th march 2024 ##
    //# Moving forward, PAT will be removed and replace with ssh private key. Accesssing repositories will be using git ssh for ArgoCD ##
    reposPatToken: {
      password: '',
      username: '',
    },
    //# ssh private key for accessing Azure DevOPS repositories, hybrid cloud service account (hybrid.cloud@skf.com)  ##
    //# In order to get this works, the repositories/projects MUST grant access to the service account ##
    reposPrivatekey: {
      privateKey: '',

    },
    eus: {
      prd: [
        'ar85b',
        'xz98d',
      ],
    },
    sea: {
      prd: [
        'in45a',
        'kr50b',
        'my56n',
        'xz98b',
        'xz98c',
        'cn47d',
      ],
    },
    weu: {
      dev: [
        'it29v',
        'pl20p',
        'se11g',
        'xz98a',
      ],
      prd: [
        'de18am',
        'se11g',
        'xz98a',
      ],
    },
  },

  subscriptions: {
    digitalManufacturing: {
      dev: {
        weu: '',
        eus: '',
        chn: '',
        sea: '',
      },
      prd: {
        weu: '',
        eus: '',
        chn: '',
        sea: '',
      },
    },
  },

  //# Access HTTPS repositories link using reposPatToken ##
  gitrepos: {
    kubeApplicationsState: 'https://dev.azure.com/skf-digital-manufacturing/SKF-DP-WCM%20Infrastructure/_git/k8s-cluster-configuration',
  },

  //# Access ssh repositories link using reposPrivatekey ##
  gitrepossshkey: {
    kubeApplicationsState: 'git@ssh.dev.azure.com:v3/skf-digital-manufacturing/SKF-DP-WCM%20Infrastructure/k8s-cluster-configuration',
  },

  servicePrincipals: import 'servicePrincipals.json',

  thanos: {
    stores: import '../clusters/thanos-endpoints.json',
  },
}

```

