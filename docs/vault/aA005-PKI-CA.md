https://developer.hashicorp.com/vault/tutorials/pki/pki-engine?variants=vault-deploy%3Aselfhosted

Enable PKI

```

vault secrets enable pki
```



Tune the `pki` secrets engine to issue certificates with a maximum time-to-live (TTL) of 87600 hours.

```
vault secrets tune -max-lease-ttl=87600h pki
```

Generate the **example.com** root CA, give it an issuer name, and save its certificate in the file `root_2023_ca.crt`.

```
vault write -field=certificate pki/root/generate/internal `
     common_name="example.com" `
     issuer_name="root-2023" `
     ttl=87600h > root_2023_ca.crt

```

Check

```
C:\Users\suresh> vault list pki/issuers/
Keys
----
198da58d-f967-5524-d73c-a482a0b13bc7
```

```
vault read pki/issuer/$(vault list -format=json pki/issuers/ | jq -r '.[]') `
 | tail -n 6
vault read pki/issuer/198da58d-f967-5524-d73c-a482a0b13bc7/issuers/ | jq -r '.[]' \
 | tail -n 6

```

Create a role for the root CA. Creating this role allows for specifying  an issuer when necessary for the purposes of this scenario. This also  provides a simple way to transition from one issuer to another by  referring to it by name.

```
vault write pki/roles/2023-servers allow_any_name=true
```

Configure the CA and CRL URLs.

```
vault write pki/config/urls `
     issuing_certificates="$Env:VAULT_ADDR/v1/pki/ca" `
     crl_distribution_points="$Env:VAULT_ADDR/v1/pki/crl"

```



Step 2 generate Intermediate CA



```
vault secrets enable -path=pki_int pki
```



Tune the `pki_int` secrets engine to issue certificates with a maximum time-to-live (TTL) of 43800 hours.

```
vault secrets tune -max-lease-ttl=43800h pki_int
```



Execute the following command to generate an intermediate and save the CSR as `pki_intermediate.csr`.

```
vault write -format=json pki_int/intermediate/generate/internal `
     common_name="example.com Intermediate Authority" `
     issuer_name="example-dot-com-intermediate" `
     | jq -r '.data.csr' > pki_intermediate.csr

```



Sign the intermediate certificate with the root CA private key, and save the generated certificate as `intermediate.cert.pem`.

```
vault write -format=json pki/root/sign-intermediate `
     issuer_ref="root-2023" `
     csr=@pki_intermediate.csr `
     format=pem_bundle ttl="43800h" `
     | jq -r '.data.certificate' > intermediate.cert.pem
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
```

```
bash ( same error as psh)
$ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
WARNING! The following warnings were returned from Vault:

  * This mount hasn't configured any authority information access (AIA)
  fields; this may make it harder for systems to find missing certificates
  in the chain or to validate revocation status of certificates. Consider
  updating /config/urls or the newly generated issuer with this information.

Key                 Value
---                 -----
existing_issuers    <nil>
existing_keys       <nil>
imported_issuers    [f53e7cea-3cd9-ee87-b97a-121b29a0dab3 2d179789-dcc7-c070-0129-b48419003d9a]
imported_keys       <nil>
mapping             map[2d179789-dcc7-c070-0129-b48419003d9a: f53e7cea-3cd9-ee87-b97a-121b29a0dab3:183783c0-cc99-bad9-8a60-54c8e4b7b0e8]


```

## Step 3: create a role

```

vault write pki_int/roles/example-dot-com \
     issuer_ref="$(vault read -field=default pki_int/config/issuers)" \
     allowed_domains="example.com" \
     allow_subdomains=true \
     max_ttl="720h"

```



## Step 4: request certificates

```
vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="24h"
```

