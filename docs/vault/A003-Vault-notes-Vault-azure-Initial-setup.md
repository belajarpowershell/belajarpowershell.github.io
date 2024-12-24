

# Vault with Azure

1. Enable Azure secrets engine

   ```
   vault secrets enable azure
   ```
   
   

2. Create SPN and assign AZ role. 

   Refer to Azure-vault-prereq.md

   ``` 
   $env:AZURE_SUBSCRIPTION_ID = "_secret_removed_"
   $env:AZURE_TENANT_ID = "_secret_removed_"
   $env:AZURE_CLIENT_ID = "_secret_removed_"
   $env:AZURE_CLIENT_SECRET = "_secret_removed_"
   
   to list
   Get-ChildItem Env: | where {$_.Name -like "AZURE*"}
   
   Bash
   export AZURE_SUBSCRIPTION_ID="_secret_removed_"
   export AZURE_TENANT_ID="_secret_removed_"
   export AZURE_CLIENT_ID="_secret_removed_"
   export AZURE_CLIENT_SECRET="_secret_removed_"
   
   printenv | grep AZURE
   
   ```

   

3. Configure Azure secrets engine with the SPN created  ( VAULT<> Azure initial setup)

   As the az role is scoped to specifically Resource Group the scope is restricted

```
# can have multiple entries.   azure/config-subscription1 > azure/config-subscription2 etc
vault write azure/config `
    subscription_id=$env:AZURE_SUBSCRIPTION_ID `
    tenant_id=$env:AZURE_TENANT_ID `
    client_id=$env:AZURE_CLIENT_ID `
    client_secret=$env:AZURE_CLIENT_SECRET `
    root_password_ttl="1h" `
    identity_token_ttl="30m" `
    use_microsoft_graph_api="true"
vault read azure/config

# to create multiple paths default azure/config
vault auth enable -path=azure-subscription1 azure
vault auth enable -path=azure-subscription2 azure

    

Validate
vault read auth/azure/config
vault delete auth/azure/config

```

3. Create Azure Roles in Vault

   ### Contributor to RG

   ```
   bash 
   vault write azure/roles/role-test-vault-dynamic-sp ttl=1h azure_roles=-<<EOF
       [
         {
           "role_name": "Contributor",
         : "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/rg-vault-dynamic-sp"
         }
       ]
   EOF
   
   not able to do via Powershell.
   $azureRolesJson = @"
   [
     {
       "role_name": "Contributor",
       "scope": "/subscriptions/$env:AZURE_SUBSCRIPTION_ID/resourceGroups/rg-vault-dynamic-sp"
     }
   ]
   "@
   
   vault write azure/roles/role-test-vault-dynamic-sp ttl=1h azure_roles=$azureRolesJson
   
   ```

   

```
bash 
vault write azure/roles/role-test-vault-dynamic-sp-read-subs ttl=1h azure_roles=-<<EOF
    [
      {
        "role_name": "Reader",
        "scope": "/subscriptions/$AZURE_SUBSCRIPTION_ID"
      }
    ]
EOF

not able to do via Powershell.



```



List Roles in path azure/roles

```
vault list azure/roles
```

