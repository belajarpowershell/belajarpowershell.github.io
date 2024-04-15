```

{
    GetStorageClassForCluster(p)::
      if std.objectHas(p,'preferred_storageclass') then p.preferred_storageclass else
      if p.type == 'aks' then 'managed-premium'
      else if p.type == 'hci' then 'hci-linux'
      else if p.type == 'k3s' then 'longhorn-one-replica' else 'unknown',
}

```

