```

First login ( after reboot etc)

Unseal Vault

#check status

vault status

# Unseal 
vault operator unseal <unseal-key>

vault operator unseal _secret_removed_
vault operator unseal_secret_removed_
vault operator unseal _secret_removed_


```



List Vault secrets

```
C:\Users\suresh> vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
azure/        azure        azure_daccea5c        n/a
cubbyhole/    cubbyhole    cubbyhole_1214a1fa    per-token private secret storage
identity/     identity     identity_5ea31905     identity store
sys/          system       system_2b396be1       system endpoints used for control, policy and debugging

```

Get azure config

```
C:\Users\suresh> vault read azure/config
Key                        Value
---                        -----
client_id                  _secret_removed_
environment                n/a
identity_token_audience    n/a
identity_token_ttl         0s
root_password_ttl          4380h
subscription_id            _secret_removed_
tenant_id                  _secret_removed_
C:\Users\suresh>

```

 **Check Enabled Authentication Methods**:

```
C:\Users\suresh> vault auth list
Path      Type     Accessor               Description                Version
----      ----     --------               -----------                -------
azure/    azure    auth_azure_ac072c3c    n/a                        n/a
token/    token    auth_token_a8245a1e    token based credentials    n/a
C:\Users\suresh>
```



#### **Inspect Azure Authentication Configuration**:

If the Azure auth method is enabled, inspect its configuration:

```

vault read auth/azure/config
Key                        Value
---                        -----
client_id                 _secret_removed_
environment                n/a
identity_token_audience    n/a
identity_token_ttl         0s
max_retries                3
max_retry_delay            7549838896000000000
resource                   https://management.azure.com/
retry_delay                9169892837000000000
root_password_ttl          4380h
tenant_id                  _secret_removed_
```





Next to create role



```
vault write auth/azure/role/my-role \
    bound_subscription_ids=<Azure Subscription ID> \
    bound_resource_groups=<Resource Group Name> \
    policies=default

export AZURE_SUBSCRIPTION_ID = "_secret_removed_"
vault write auth/azure/role/owner-role \
    bound_subscription_ids="_secret_removed_" \
    bound_resource_groups=TestResourceGroup \
    policies=default

```

