#https://learn.microsoft.com/en-us/azure/aks/azure-ad-integration-cli

## Create Microsoft Entra server component

aksname="myakscluster"
# Create the Azure AD application

# Create the Azure AD application
serverApplicationId=$(az ad app create --display-name "${aksname}Server" --identifier-uris "https://sureshsolomonyahoo.onmicrosoft.com" --query appId -o tsv)

# Update the application group membership claims
az ad app update --id $serverApplicationId --set groupMembershipClaims=All 


# Create a service principal for the Azure AD application
az ad sp create --id $serverApplicationId

# Get the service principal secret
#serverApplicationSecret=$(az ad sp credential reset --id ${serverApplicationId} --credential-description "AKSPassword" --query password -o tsv)
serverApplicationSecret=$(az ad sp credential reset --id ${serverApplicationId} --query password -o tsv)

###   Read directory data
###    Sign in and read user profile

az ad app permission add --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role

# grant the permissions assigned in the previous step for the server application using the az ad app permission grant command. This step fails if the current account is not a 

az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000 --scope "user.read , Directory.Read.All "
az ad app permission admin-consent --id  $serverApplicationId

# Create Microsoft Entra client component
clientApplicationId=$(az ad app create --display-name "${aksname}Client"  --web-redirect-uris "https://localhost" --query appId -o tsv)


az ad sp create --id $clientApplicationId
oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)
az ad app permission list --id $serverApplicationId --query "resourceAccess[0].id"
#followong is not workig as oAuthPermissionId is blank
az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions ${oAuthPermissionId}=Scope
Manual steps. 
1. expose API on myaksclusterServer .
2. Once the API is created, the API is now visible on the myaksclusterClient
3. from myaksclusterClient ,API permissions> add permission (APIs my organization uses),myaksclusterServer
4. from k3s cluster, create ClusterRole and ClusterRoleBinding.
5. 


