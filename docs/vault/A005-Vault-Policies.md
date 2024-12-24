### Policies dictate the Vault Path access and the roles associated







https://developer.hashicorp.com/vault/tutorials/pki/pki-engine?variants=vault-deploy%3Aselfhosted

```
PKI-policy.hcl 


# Enable secrets engine
path "sys/mounts/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# List enabled secrets engine
path "sys/mounts" {
  capabilities = [ "read", "list" ]
}

# Work with pki secrets engine
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo", "patch" ]
}
```

