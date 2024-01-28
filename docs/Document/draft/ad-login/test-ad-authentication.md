https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc


https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/authorize
?client_id={client_id}
&response_type=code
&redirect_uri={redirect_uri}
&response_mode=query
&scope={scopes}


https://login.microsoftonline.com/a01c77f7-d822-4d88-88fd-9a738c46e3ab/oauth2/v2.0/authorize
?client_id=9f409b8b-ef4c-4457-bb1b-1f7bdb9cfdf5
&response_type=code
&redirect_uri=https://jwt.ms/
&scope=openid User.Read Group.Read.All

https://login.microsoftonline.com/a01c77f7-d822-4d88-88fd-9a738c46e3ab/oauth2/v2.0/token
  ?client_id=1183f353-92b5-493d-97cd-9749773dd79b
  &scope=openid
  &grant_type=client_credentials

to list all the openid config values  for the above options
https://login.microsoftonline.com/a01c77f7-d822-4d88-88fd-9a738c46e3ab/.well-known/openid-configuration


### Key app registration configuration required
1. App id/ client id
2. Tenant id
3. authentication
    add redirect URL 
    check 
    Access tokens (used for implicit flows)
    ID tokens (used for implicit and hybrid flows)
    Allow public client flows > yes
