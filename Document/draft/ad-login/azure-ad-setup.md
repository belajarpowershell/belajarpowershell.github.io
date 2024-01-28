App Registration
>application / Client ID
> tenant ID 
> ObjectID ( not used much)

>> API permission
- MS Graph
- - openid,email, group  etc permission for application to access/

> Client secrets

###########


API permissions
> MS Graph> Delegated > under OpenID Permission
Add email and profile under openid

Authentication 
> Advanced settings >> change to yes
##########
Enterprise application ( list of SP) by tenant
Service Principals 
Scope , consent , token

name :kubectl-ent-app-ad-login
**** Application (client) ID: d4b86a76-3c21-464a-ae67-8b15eaf6ee87


```
users:
- name: azure-add-user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - get-token
      - --environment
      - AzurePublicCloud
      - --server-id * ( for SSO)
      - 9f409b8b-ef4c-4457-bb1b-1f7bdb9cfdf5
      - --client-id **** ( for kubectl RBAC)
      - c7fbbe69-7a9c-472c-a0e5-8e1665515720
      - --tenant-id
      - a01c77f7-d822-4d88-88fd-9a738c46e3ab
      - --legacy
      command: kubelogin
      env: null
      interactiveMode: IfAvailable
      provideClusterInfo: false

```
kubectl config set-credentials "azure-add-user" \
  --exec-api-version=client.authentication.k8s.io/v1beta1 \
  --exec-command=kubelogin \
  --exec-arg=get-token \
  --exec-arg=--environment \
  --exec-arg=AzurePublicCloud \
  --exec-arg=--server-id \
  --exec-arg=9f409b8b-ef4c-4457-bb1b-1f7bdb9cfdf5 \
  --exec-arg=--client-id \
  --exec-arg=c7fbbe69-7a9c-472c-a0e5-8e1665515720 \
  --exec-arg=--tenant-id \
  --exec-arg=a01c77f7-d822-4d88-88fd-9a738c46e3ab\
  --exec-arg=--legacy

```
kubelogin --client-id c7fbbe69-7a9c-472c-a0e5-8e1665515720 --tenant-id a01c77f7-d822-4d88-88fd-9a738c46e3ab --server-id 9f409b8b-ef4c-4457-bb1b-1f7bdb9cfdf5 --login devicecode


Request Id: bb97976a-a7b1-4bb6-9ccb-27074cc76102
Correlation Id: 55c40d37-3321-4ed2-a00f-75364b8e3792
Timestamp: 2023-12-24T13:06:25Z
Message: AADSTS650057: Invalid resource. The client has requested access to a resource which is not listed in the requested permissions in the client's application registration. Client app ID: d4b86a76-3c21-464a-ae67-8b15eaf6ee87(kubectl-ent-app-ad-login). Resource value from request: ccf2ea19-40ae-400a-a97a-928ad0e8614c. Resource app ID: ccf2ea19-40ae-400a-a97a-928ad0e8614c. List of valid resources from app registration: 00000003-0000-0000-c000-000000000000.
```