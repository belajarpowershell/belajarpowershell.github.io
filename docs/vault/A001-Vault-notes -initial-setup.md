

https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent/winsvc

Start vault as  service

PS C:\Windows\system32> sc.exe create VaultAgent binPath="C:\vault\vault.exe agent -config=C:\vault\agent-config.hcl" displayName="Vault Agent" start=auto
[SC] CreateService SUCCESS





F:\vault\

F:\vault\config.hcl

Vault IP= 192.168.0.148



```
<F:\vault\config.hcl>
storage "file" {
  path    = "f:/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr = "http://192.168.0.148:8200"
ui = true
disable_mlock = true
```





```
PS C:\Windows\system32> New-Service -Name "VaultServer" -BinaryPathName '"F:\vault\vault.exe" server -config="F:\vault\config.hcl"' -DisplayName "VaultServer" -StartupType "Automatic"

Status   Name               DisplayName
------   ----               -----------
Stopped  VaultAgent         Vault Agent


#start vault
Start-Service -Name "VaultServer"
restart-Service -Name "VaultServer"
```



```
"F:\vault\vault-cluster-vault-2024-12-04T14_24_25.349Z.json"

Initial root token

hvs._secret_removed_

Key1
_secret_removed_

key2 
_secret_removed_

key3 
_secret_removed_

```



```
Set as env variable >Win + S and search for Environment Variables.
$env.VAULT_ADDR = "http://192.168.0.148:8200"

check with 
$env.VAULT_ADDR

Bash
export VAULT_ADDR="http://192.168.0.148:8200"

$ printenv | grep VAULT
VAULT_ADDR=http://192.168.0.148:8200


```



Generate new token for Vault

```
vault login <INITIAL_ROOT_TOKEN>
vault operator generate-root -init
vault operator generate-root # run 2 times and provide unseal key.
vault operator generate-root -decode=$ENCODED_TOKEN -otp=$OTP

```

```
C:\Users\suresh> vault operator generate-root -init
A One-Time-Password has been generated for you and is shown in the OTP field.
You will need this value to decode the resulting root token, so keep it safe.
Nonce         b44f61b1-f481-2f1c-5518-b20cff143836
Started       true
Progress      0/2
Complete      false
OTP           _secret_removed_
OTP Length    28
C:\Users\suresh> vault operator generate-root
Operation nonce: b44f61b1-f481-2f1c-5518-b20cff143836
Unseal Key (will be hidden):

Nonce       b44f61b1-f481-2f1c-5518-b20cff143836
Started     true
Progress    1/2
Complete    false
C:\Users\suresh> vault operator generate-root
Operation nonce: b44f61b1-f481-2f1c-5518-b20cff143836
Unseal Key (will be hidden):

Nonce            b44f61b1-f481-2f1c-5518-b20cff143836
Started          true
Progress         2/2
Complete         true
Encoded Token    HxAgXBcJACcjAlNVRRIALh0CZAIEPwNxaXxkEA
C:\Users\suresh> vault operator generate-root -decode=$ENCODED_TOKEN -otp=$OTP
Error decoding root token: error decoding base64'd token: illegal base64 data at input byte 0
C:\Users\suresh> vault operator generate-root -decode=HxAgXBcJACcjAlNVRRIALh0CZAIEPwNxaXxkEA -otp=_secret_removed_
hvs._secret_removed_
C:\Users\suresh>
```



First login ( after reboot etc) -Unseal Vault

```
#check status

vault status

# Unseal 
vault operator unseal <unseal-key>

vault operator unseal _secret_removed_
vault operator unseal _secret_removed_
vault operator unseal _secret_removed_


```



Vault login

```
bash
# root token
vault login hvs._secret_removed_

```

