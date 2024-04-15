```

kubectl get engineimage -n longhorn-system -o yaml

kubectl get volume -n longhorn-system

Delete CRD not removed after deleting longhorn.
for crd in $(kubectl get crd -o name | grep longhorn); do kubectl delete $crd ; done;

Remove finalizers.
for crd in $(kubectl get crd -o name | grep longhorn); do kubectl patch $crd -p '{"metadata":{"finalizers":[]}}' --type=merge; done;

List all elements in longhorn ns
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n longhorn-system
```





```
deploy temp pod to create pvc

kubectl create -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.3/examples/pod_with_pvc.yaml

```





#### This PVC creation is succesful.

```
cat <<EOF > test-pvc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx
    volumeMounts:
    - name: my-volume
      mountPath: /data
  volumes:
  - name: my-volume
    persistentVolumeClaim:
      claimName: my-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: longhorn  # Use the desired StorageClass here
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi  # Adjust the size of the PVC as needed
EOF
```





```
This following error indicates the storage cannot meet the pod storage request. Check the PVC capacity and the Pod PVC storage request to ensure the request is within limits.

kubectl get events ( namespace where pvc pod is created)
11h         Warning   FailedScheduling          pod/my-pod                                0/6 nodes are available: 6 persistentvolumeclaim "my-pvc" not found. preemption: 0/6 nodes are available: 6 Preemption is not helpful for scheduling.
11h         Warning   FailedScheduling          pod/my-pod                                0/6 nodes are available: 6 pod has unbound immediate PersistentVolumeClaims. preemption: 0/6 nodes are available: 6 Preemption is not helpful for scheduling.

```



```
```

