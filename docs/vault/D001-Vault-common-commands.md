Enable Azure secrets engine

```
vault secrets enable azure

Enabled the azure secrets engine at: azure/

```

Check

```
```



Create Vault <> Azure initial setup

```

vault write azure/config `
    subscription_id=$env:AZURE_SUBSCRIPTION_ID `
    tenant_id=$env:AZURE_TENANT_ID `
    client_id=$env:AZURE_CLIENT_ID `
    client_secret=$env:AZURE_CLIENT_SECRET `
    root_password_ttl="1h" `
    identity_token_ttl="30m"

```

Validate

```
vault read auth/azure/config
```



Get all configuraton



```
1. List Authentication Methods
vault auth list


1a. read specific config from step 1
vault read auth/azure/config

2. List Secrets Engines
vault secrets list

2a. read specific from step 2
vault read azure/config

3.List All Mounted Paths
vault list sys/mounts

4. List Policies
vault policy list

5. debugging
vault read sys/mounts

vault read sys/config/state/sanitized

+++++++++++++++++++
vault read azure/config
vault read auth/azure/config
vault read auth/azure/role/test-role-testresourcegroup
> vault delete auth/azure/role/test-role-testresourcegroup
vault read azure/roles/my-testresourcegroup-role
>vault delete azure/roles/my-testresourcegroup-role

vault policy list
> vault policy delete test-policy-testresourcegroup

vault secrets list
>vault secrets disable kv
```



Extract vault list sys/mounts using web

```
$response = Invoke-WebRequest -Uri "http://127.0.0.1:8200/v1/sys/mounts" `
    -Headers @{"X-Vault-Token"="hvs._secret_removed_"}

$response.Content | ConvertFrom-Json | Format-List

C:\Users\suresh> $response.Content | ConvertFrom-Json | Format-List


sys/           : @{accessor=system_2b396be1; config=; description=system endpoints used for control, policy and
                 debugging; external_entropy_access=False; local=False; options=; plugin_version=;
                 running_plugin_version=v1.18.2+builtin.vault; running_sha256=; seal_wrap=True; type=system;
                 uuid=ea4a8abd-83ae-f58a-deab-f97ba24b28a3}
identity/      : @{accessor=identity_5ea31905; config=; description=identity store; external_entropy_access=False;
                 local=False; options=; plugin_version=; running_plugin_version=v1.18.2+builtin.vault; running_sha256=;
                 seal_wrap=False; type=identity; uuid=c80c010f-bb0e-d7ef-be62-b92e47f61227}
azure/         : @{accessor=azure_daccea5c; config=; deprecation_status=supported; description=;
                 external_entropy_access=False; local=False; options=; plugin_version=;
                 running_plugin_version=v0.20.1+builtin; running_sha256=; seal_wrap=False; type=azure;
                 uuid=71f7966e-77be-07b2-bdd4-6c1947810ecc}
cubbyhole/     : @{accessor=cubbyhole_1214a1fa; config=; description=per-token private secret storage;
                 external_entropy_access=False; local=True; options=; plugin_version=;
                 running_plugin_version=v1.18.2+builtin.vault; running_sha256=; seal_wrap=False; type=cubbyhole;
                 uuid=4c99b6d7-ccac-4be0-9dc2-57874a43053a}
kv/            : @{accessor=kv_3f43a3ca; config=; deprecation_status=supported; description=;
                 external_entropy_access=False; local=False; options=; plugin_version=;
                 running_plugin_version=v0.20.0+builtin; running_sha256=; seal_wrap=False; type=kv;
                 uuid=d2ba8f3a-1f8a-0e77-6354-d896fedf6994}
request_id     : cc33b5e5-e209-a45e-9842-d9b6a379d78a
lease_id       :
renewable      : False
lease_duration : 0
data           : @{azure/=; cubbyhole/=; identity/=; kv/=; sys/=}
wrap_info      :
warnings       :
auth           :
mount_type     : system


```

