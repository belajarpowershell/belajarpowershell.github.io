```
local kube = import 'kube.libsonnet';
local kubeExtensions = import 'kubeExtensions.libsonnet';

{
  ExternalSecret(p):: kubeExtensions.ExternalSecret(p.name) {
    spec: {
      backendType: 'azureKeyVault',
      keyVaultName: p.keyVaultName,
      data: [
        {
          name: item.name,
          key: item.key,
          property: 'value',
        }
        for item in p.data
      ],
    },
  },

  ExternalSecretFromList(name, keyVaultName, data):: kubeExtensions.ExternalSecret(name) {
    spec: {
      backendType: 'azureKeyVault',
      keyVaultName: keyVaultName,

      local this = self,

      envList(map):: [
        {
          // Let `null` value stay as such (vs string-ified)
          name: x,
          key: if map[x] == null then null else std.toString(map[x]),
          property: 'value',
        }
        for x in std.objectFields(map)
      ],

      data: this.envList(data),
    },
  },
}



```

