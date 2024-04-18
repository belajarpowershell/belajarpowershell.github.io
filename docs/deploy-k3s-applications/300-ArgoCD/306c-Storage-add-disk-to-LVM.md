# Storage addition

 With Storage there will be a number of scenarios where you will have to add storage size.

#### Add new disk (10GB) and increase `/longhorn_data`

1. From HyperV add new Disk to VM.

   ```
   lsblk
   ubuntu@worker1:~$ lsblk
   NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   
   └─sda3                        8:3    0   47G  0 part
     └─ubuntu--vg-ubuntu--lv   253:1    0 23.5G  0 lvm  /
   sdb                           8:16   0   30G  0 disk
   └─sdb1                        8:17   0    3G  0 part
     └─longhorn_vg-longhorn_lv 253:0    0    3G  0 lvm  /longhorn_data
   sdc                           8:32   0   10G  0 disk  >> new disk
   
   ```
   
2. Create partition using fdisk
   
   ```
   ubuntu@worker1:~$ sudo fdisk /dev/sdc
   
   Welcome to fdisk (util-linux 2.34).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.
   
   Device does not contain a recognized partition table.
   Created a new DOS disklabel with disk identifier 0x31abc25b.
   
   Command (m for help): p
   Disk /dev/sdc: 10 GiB, 10737418240 bytes, 20971520 sectors
   Disk model: Virtual Disk
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 4096 bytes
   Disklabel type: dos
   Disk identifier: 0x31abc25b
   
   Command (m for help): n
   Partition type
      p   primary (0 primary, 0 extended, 4 free)
      e   extended (container for logical partitions)
   Select (default p): p
   Partition number (1-4, default 1):
   First sector (2048-20971519, default 2048):
   Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-20971519, default 20971519):
   
   Created a new partition 1 of type 'Linux' and of size 10 GiB.
   
   Command (m for help): w
   The partition table has been altered.
   Calling ioctl() to re-read partition table.
   Syncing disks.
   
   ```
   
   
   
3.  `lsblk` will show sdc-sdc1 created with 10G

   

4. Add `/dev/sdc1` to the existing Volume Group `longhorn_vg`.

   ```
   
   ubuntu@worker1:~$ sudo vgextend longhorn_vg /dev/sdc1
     Physical volume "/dev/sdc1" successfully created.
     Volume group "longhorn_vg" successfully extended
   ```

   Check if the Size is increased

   ```
   Free space has increased on the Volume Group
   ubuntu@worker1:~$ sudo vgdisplay
     --- Volume group ---
     VG Name               longhorn_vg
     System ID
     Format                lvm2
     Metadata Areas        2
     Metadata Sequence No  4
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                1
     Open LV               1
     Max PV                0
     Cur PV                2
     Act PV                2
     VG Size               12.99 GiB
     PE Size               4.00 MiB
     Total PE              3326
     Alloc PE / Size       767 / <3.00 GiB
     Free  PE / Size       2559 / <10.00 GiB  >>>> Increased
     VG UUID               tDUPQx-mLKx-mxYW-1HJu-V5HU-o5U6-GXwU09
   
   ```

   

5.  Extend the LVM `longhorn_lv`

   ```
   
   sudo lvextend -r -l +100%FREE  /dev/longhorn_vg/longhorn_lv  
   ( get device name from lvdisplay)
   
   # to increase by specific size use this + is important else the existing will be replaced.
   sudo lvextend -r -L +2G  /dev/longhorn_vg/longhorn_lv 
   ```

6.  Longhorn Portal will reflect the changes 

   Verify capacity with `lsblk` ,`pvs`, `vgs` and longhorn portal for updated disk size

   ```
   ubuntu@worker1:~$ lsblk
   NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   sdb                           8:16   0   30G  0 disk
   └─sdb1                        8:17   0    3G  0 part
     └─longhorn_vg-longhorn_lv 253:0    0   13G  0 lvm  /longhorn_data
   sdc                           8:32   0   10G  0 disk
   └─sdc1                        8:33   0   10G  0 part
     └─longhorn_vg-longhorn_lv 253:0    0   13G  0 lvm  /longhorn_data
   
   ubuntu@worker1:~$ sudo pvs
     PV         VG          Fmt  Attr PSize   PFree
     /dev/sdb1  longhorn_vg lvm2 a--   <3.00g     0
     /dev/sdc1  longhorn_vg lvm2 a--  <10.00g     0
   
   ubuntu@worker1:~$ sudo lvs
   LV VG  Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
     longhorn_lv longhorn_vg -wi-ao---- 12.99g
     ubuntu-lv   ubuntu-vg   -wi-ao---- 23.47g
   
   ubuntu@worker1:~$ sudo vgs
     VG          #PV #LV #SN Attr   VSize   VFree
     longhorn_vg   2   1   0 wz--n-  12.99g     0
     ubuntu-vg     1   1   0 wz--n- <46.95g 23.47g
   
   ```

   



