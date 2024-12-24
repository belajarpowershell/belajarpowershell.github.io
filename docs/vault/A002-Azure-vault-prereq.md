Create SPN ( specific to ResourceGrpup)

Additional **Microsoft Graph** permissions required

https://developer.hashicorp.com/vault/tutorials/secrets-management/azure-secrets



```

 az ad sp create-for-rbac --name "<spn-name>" --role <role> --scopes <scope>
az ad sp create-for-rbac --name "spn-contributor-vault" --role "Contributor" --scopes "/subscriptions/_secret_removed_/resourceGroups/TestResourceGroup"

{
  "appId": "_secret_removed_", // SPN Client ID
  "displayName": "spn-contributor-vault",
  "password": "_secret_removed_",
  "tenant": "_secret_removed_"
}
az ad sp list -o table  >> list all spn


Verify (not yeat created) >> no data
az role assignment list --assignee <appId>
az role assignment list --assignee _secret_removed_

Test login
az login --service-principal --username <appId> --password <password> --tenant <tenant>
az login --service-principal --username _secret_removed_ --password _secret_removed_ --tenant _secret_removed_



az ad app update --id <objectId> --display-name "new-display-name"


```



Set as env variable for Vault

```

$env:AZURE_SUBSCRIPTION_ID = "_secret_removed_"
$env:AZURE_TENANT_ID = "_secret_removed_"
$env:AZURE_CLIENT_ID = "_secret_removed_"
$env:AZURE_CLIENT_SECRET = "_secret_removed_"
echo %AZURE%

```



Assign Role to SPN ( can assign multiple roles)

```
az role assignment create \
    --assignee <SPN Client ID> \
    --role "Owner" \
    --scope "/subscriptions/_secret_removed_"

# create role with access to subcription ( Contributor and Reader) did not work with Contributor alone
az role assignment create `
    --assignee _secret_removed_ `
    --role "Contributor" `
    --scope "/subscriptions/_secret_removed_"
    
az role assignment create `
    --assignee _secret_removed_ `
    --role "Reader" `
    --scope "/subscriptions/_secret_removed_"
# update role with access to specific RG
#delete existing role assignment
az role assignment delete `
    --assignee _secret_removed_ `
    --role "Contributor" `
    --scope "/subscriptions/_secret_removed_/resourceGroups"

# 
az role assignment create `
    --assignee _secret_removed_ `
    --role "Contributor" `
    --scope "/subscriptions/_secret_removed_/resourceGroups/TestResourceGroup"


Verify (must find roles assigned) and get 'principalId' for next step
az role assignment list --assignee <appId>
az role assignment list --assignee _secret_removed_

```

```
Summary of what was done
1. SPN created with role assignment ( contributor) for specific scope ( resource group) { this is supposed to create step 2 but does not}
2. assigned role to SPN created ( Contributor and Reader) for specific scope ( resource group)

SPN created
1. Subscription level
{
  "appId": "_secret_removed_",
  "displayName": "spn-contributor-vault",
  "password": "_secret_removed_",
  "tenant": "_secret_removed_"
}

2.RG level ( Deleted)
{
  "appId": "_secret_removed_",
  "displayName": "spn-rg-contributor-vault",
  "password": "_secret_removed_",
  "tenant": "_secret_removed_"
}

Roles assigned
Contributor at the RG level.

az role assignment list --assignee _secret_removed_

```



Can perform Auto unseal using Azure Key Vault

```
https://developer.hashicorp.com/vault/tutorials/auto-unseal/autounseal-azure-keyvault
```



