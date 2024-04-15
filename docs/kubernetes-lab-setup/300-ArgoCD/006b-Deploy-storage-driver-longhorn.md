

#### Pre deployment steps

Create the mount points on the worker nodes and mount it for use.

the volume mount name must be same across Worker the nodes. The is a minimum size for storage 











-------------------

https://longhorn.io/docs/1.6.1/deploy/install/install-with-helm/

#### install from local helm charts. 

```

helm pull   jetstack/cert-manager --version 1.14.4
mkdir cert-manager-v1.14.4
tar -xvf cert-manager-v1.14.4.tgz --strip-components=1 -C \cert-manager-v1.14.4


helm install cert-manager ./cert-manager-v1.14.4 -f ./cert-manager-v1.14.4/values.yaml --namespace cert-manager --create-namespace --set installCRDs=true

````





```

helm repo add longhorn https://charts.longhorn.io
helm repo update
helm pull   longhorn/longhorn --version 1.5.3
mkdir longhorn-1.5.3
tar -xvf longhorn-1.5.3.tgz --strip-components=1 -C \longhorn-1.5.3

```





Manual deploy to troubleshoot

```
helm install longhorn ./longhorn-1.5.3 -f ./longhorn-1.5.3/values.yaml --namespace longhorn-system --create-namespace

helm upgrade -f ./longhorn-1.5.3/values.yaml  longhorn ./longhorn-1.5.3 --version 1.5.3 -n longhorn-system --reuse-values 

helm verify -f ./longhorn-1.5.3/values.yaml  longhorn ./longhorn-1.5.3 --version 1.5.3 -n longhorn-system

```



https://longhorn.io/docs/1.6.1/deploy/install/install-with-argocd/

Location of storage to be mounted by Longhorn

````
defaultSettings:
  defaultDataPath: /var/lib/longhorn-example/  # change to the mount point on the workernode.
  
````



```
cat <<EOF > app-of-apps/templates/longhorn-app-of-apps.yaml 

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: longhorn
  namespace: argocd
  finalizers:
  - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/belajarpowershell/k3s-repository.git
    path: clusters/ctx-k3s-cluster-77/longhorn-1.5.3
    targetRevision: HEAD
    helm:
      valueFiles:
      - values.yaml
      releaseName: longhorn
      parameters:
      - name: app
        value: longhorn
  destination:
    server: https://kubernetes.default.svc
    namespace: longhorn-system
  syncPolicy:
    #automated:
      #prune: true
      #selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF

kubectl apply -f longhorn-app-of-apps.yaml

```



#### ingress

```
In values file update to enable ingress and provide nginx class name >> "nginx"

Update DNS to be able to 

vi /etc/bind/master/k8s.lab
argocd          IN      A       192.168.100.208
longhorn          IN      A       192.168.100.208

Restart 

# (re)start bind service. ( the service name is 'named') 
rc-service named restart 
```



#### Configure Longhorn storage to use specific partition.

#### check if iscsi is installed

```
Ubuntu installed by default.

 ps -ef | grep iscsi

```



nfs installtion

```
to install nfs on ubuntu

apt-get install nfs-common

# autoinstall using script
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.5/deploy/prerequisite/longhorn-nfs-installation.yaml
```







#### Create /data mount point on Worker node



````
1. lsblk

ubuntu@worker1:~$ lsblk
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                       7:0    0 63.9M  1 loop /snap/core20/2182
loop1                       7:1    0 91.9M  1 loop /snap/lxd/24061
loop2                       7:2    0 49.9M  1 loop /snap/snapd/18357
loop3                       7:3    0 63.3M  1 loop /snap/core20/1828
loop4                       7:4    0 39.1M  1 loop /snap/snapd/21184
sda                         8:0    0   50G  0 disk
├─sda1                      8:1    0  1.1G  0 part /boot/efi
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   47G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0 23.5G  0 lvm  /
sdb                         8:16   0   30G  0 disk     >>>>
sr0                        11:0    1  1.4G  0 rom


2. sudo mkdir /data


 
````



Create partition

```
#Create a New Partition:
    Once inside fdisk, you can create a new partition by following these steps:

    Press n to create a new partition.
    Choose the partition type, typically p for primary partition.
    Specify the partition number.
    Specify the starting and ending sectors or simply press Enter to accept the default values (which will 		use the entire disk)

sudo fdisk /dev/sdb


#format partition
sudo mkfs.ext4 /dev/sdb1


3. Permanant mount
vi /etc/fstab
 
 /dev/sdX1   /data   ext4   defaults   0   0
 /dev/sdb1    /data   ext4   defaults   0   0

# 
sudo mount /dev/sdb1 /data


#to reload all mounts on /etc/fstab
sudo mount -a

```





#### create LVM group



To create a Logical Volume using LVM (Logical Volume Management) on Ubuntu, you'll typically follow these steps:

1. **Prepare the Disk**:
   If the disk you want to use isn't already partitioned, you can create a partition using a tool like `fdisk` or `parted`. For example, if the disk you want to use is `/dev/sdb`, you could use `fdisk` as follows:
   ```
   sudo fdisk /dev/sdb
   ```
   Then create a new partition (type `n`) and write the changes (type `w`).

2. **Create Physical Volume (PV)**:
   Once the partition is created, you need to mark it as a physical volume for LVM. Use the `pvcreate` command:
   ```
   sudo pvcreate /dev/sdb1
   ```
   Replace `/dev/sdb1` with the actual partition you created.

3. **Create Volume Group (VG)**:
   After creating the physical volume, you can group it with other physical volumes (if desired) into a volume group. Use the `vgcreate` command:
   
   ```
   sudo vgcreate my_vg /dev/sdb2
   
   sudo vgcreate longhorn_vg /dev/sdb1
   
   ```
   Replace `my_vg` with the desired name for your volume group.
   
4. **Create Logical Volume (LV)**:
   Once the volume group is created, you can create logical volumes within it. Use the `lvcreate` command:
   ```
   sudo lvcreate -n my_lv -L 10G my_vg
   
   sudo lvcreate -n longhorn_lv -L 1G longhorn_vg
   
   ```
   This creates a logical volume named `my_lv` with a size of 10GB in the `my_vg` volume group.
   
5. **Format the Logical Volume**:
   After creating the logical volume, you need to format it with a filesystem. For example, to format it with ext4:
   ```
   sudo mkfs.ext4 /dev/my_vg/my_lv
   sudo mkfs.ext4 /dev/longhorn_vg/longhorn_lv
   
   ```
   Replace `/dev/my_vg/my_lv` with the path to your logical volume.
   
6. **Mount the Logical Volume**:
   Finally, you can mount the logical volume to a mount point. For example, to mount it to `/mnt/my_lv`:
   ```
   sudo mkdir /mnt/my_lv
   sudo mount /dev/my_vg/my_lv /mnt/my_lv
   
   sudo mkdir /longhorn_data
   sudo mount /dev/longhorn_vg/longhorn_lv /longhorn_data
   
   Permanant mount
   sudo vi /etc/fstab
    
    /dev/sdX1   /data   ext4   defaults   0   0
    /dev/longhorn_vg/longhorn_lv    /longhorn_data   ext4   defaults   0   0
   
   # 
   sudo mount /dev/sdb1 /data
   
   
   #to reload all mounts on /etc/fstab
   sudo mount -a
   
   ```

That's it! You've created a logical volume using LVM on Ubuntu. You can now use the logical volume like any other disk partition, and it will benefit from the flexibility and management features provided by LVM.





### Expand LV



```
ubuntu@worker2:~$ sudo vgdisplay
  --- Volume group ---
  VG Name               longhorn_vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <2.00 GiB   ## << total size
  PE Size               4.00 MiB
  Total PE              511
  Alloc PE / Size       256 / 1.00 GiB   ##<< currently in use
  Free  PE / Size       255 / 1020.00 MiB  ## << available for expansion
  VG UUID               T9frRY-iX7U-dF9B-DSeo-3ZbH-8GVX-Jubcbl

```





```
ubuntu@worker2:~$ sudo lvs
  LV          VG          Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  longhorn_lv longhorn_vg -wi-ao----  1.00g
  ubuntu-lv   ubuntu-vg   -wi-ao---- 23.47g
```



```
 sudo lvextend -l +100%FREE  /dev/longhorn_vg/longhorn_lv
  Size of logical volume longhorn_vg/longhorn_lv changed from 1.00 GiB (256 extents) to <2.00 GiB (511 extents).
  Logical volume longhorn_vg/longhorn_lv successfully resized.

```



