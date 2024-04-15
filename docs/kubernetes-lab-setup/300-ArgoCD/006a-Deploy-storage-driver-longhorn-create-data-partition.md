

#### Pre deployment steps

Create the mount points on the worker nodes and mount it for use.

the volume mount name must be same across Worker the nodes. The is a minimum size for storage .



https://packetpushers.net/blog/ubuntu-extend-your-default-lvm-space/

![LVM high level ](https://packetpushers.net/wp-content/uploads/2021/11/1-linux-ubuntu-lvm-diagram.jpg)

#### Create LVM group

Check the current partition information `lsblk`

```

ubuntu@worker1:~$ lsblk
NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0                         7:0    0 63.3M  1 loop /snap/core20/1828
loop1                         7:1    0 49.9M  1 loop /snap/snapd/18357
loop2                         7:2    0 91.9M  1 loop /snap/lxd/24061
sda                           8:0    0   50G  0 disk
├─sda1                        8:1    0  1.1G  0 part /boot/efi
├─sda2                        8:2    0    2G  0 part /boot
└─sda3                        8:3    0   47G  0 part
  └─ubuntu--vg-ubuntu--lv   253:1    0 23.5G  0 lvm  /
sdb                           8:16   0   30G  0 disk
└─sdb1                        8:17   0    2G  0 part
  └─longhorn_vg-longhorn_lv 253:0    0    1G  0 lvm
sr0                          11:0    1  1.4G  0 rom

###
Deleting `longhorn_vg-longhorn_lv` did not reflect until WM was rebooted.

```



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
   sudo vgcreate longhorn_vg /dev/sdb1
   
   ```
   
   Replace `my_vg` with the desired name for your volume group.

4. **Create Logical Volume (LV)**:
   Once the volume group is created, you can create logical volumes within it. Use the `lvcreate` command:

   ```
   sudo lvcreate -n longhorn_lv -L 2G longhorn_vg
   
   ```
   
   This creates a logical volume named `longhorn_lv` with a size of 2GB in the `longhorn_vg` volume group.

5. **Format the Logical Volume**:
   After creating the logical volume, you need to format it with a filesystem. For example, to format it with ext4:

   ```
   # format to ext4 filesystem
   sudo mkfs.ext4 /dev/longhorn_vg/longhorn_lv
   ## sudo mkfs.xfs /dev/longhorn_vg/longhorn_lv
   
   # format to xfs , can resize directly
   
   Expand Filesystem
   if the filesystem is xfs, you can directly mount, then expand the filesystem.
   
   mount /dev/longhorn/<volume name> <arbitrary mount directory>
   xfs_growfs <the mount directory>
   umount /dev/longhorn/<volume name>
   
   
   ```
   
   Replace `/dev/my_vg/my_lv` with the path to your logical volume.
   
6. **Mount the Logical Volume**:
   Finally, you can mount the logical volume to a mount point. For example, to mount it to `/mnt/my_lv`:

   ```
   sudo mkdir /longhorn_data
   sudo mount /dev/longhorn_vg/longhorn_lv /longhorn_data
   
   Permanant mount
   sudo vi /etc/fstab
    
    #/dev/sdX1   /data   ext4   defaults   0   0
   /dev/longhorn_vg/longhorn_lv    /longhorn_data   ext4   defaults   0   0
   ## /dev/longhorn_vg/longhorn_lv    /longhorn_data   xfs   defaults   0   0
   #mount manually 
   sudo mount /dev/sdb1 /longhorn_data
   
   
   #to reload all mounts on /etc/fstab
   sudo mount -a
   
   ```

That's it! You've created a logical volume using LVM on Ubuntu. You can now use the logical volume like any other disk partition, and it will benefit from the flexibility and management features provided by LVM.


