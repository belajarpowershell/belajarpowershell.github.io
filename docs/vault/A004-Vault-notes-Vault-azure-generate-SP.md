

# Generate Service Principal

Contributor SPN to RG

```
vault read azure/creds/role-test-vault-dynamic-sp
Key                Value
---                -----
lease_id           azure/creds/role-test-vault-dynamic-sp/u0t5rBTt5FU8cejSQ6YiR34h
lease_duration     1h
lease_renewable    true
client_id          _secret_removed_
client_secret      _secret_removed_


SPN created
spn name: vault-d275631f-6e5c-4c5b-9ec2-0601a8e44ea2
appid :_secret_removed_
objid : _secret_removed_

```

Check access of the SPN created 

 Azure Roles assigned to this SPN.

```
az ad sp show --id <SPN-app-id> --query objectId
az ad sp show --id _secret_removed_ --query _secret_removed_

```



Readonly SPN to Subs

```
vault read azure/creds/role-test-vault-dynamic-sp-read-subs

Key                Value
---                -----
lease_id           azure/creds/role-test-vault-dynamic-sp-read-subs/erDJvRpWFLql9psxsZNFRUgd
lease_duration     1h
lease_renewable    true
client_id         _secret_removed_
client_secret      _secret_removed_


```

