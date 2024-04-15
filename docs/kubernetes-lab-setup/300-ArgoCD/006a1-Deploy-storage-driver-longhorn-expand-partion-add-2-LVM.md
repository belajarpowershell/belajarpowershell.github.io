
#### expand  partion to 10GB  and increase `/longhorn_data`

1. Use `cfdisk` to increase partition size

   ```
   lsblk for dev details
   sudo cfdisk  /dev/sdb1
   
   expand 3GB to 10GB
   ```

   

2. Check PV status. Reflects the increased size.

   ```
   ubuntu@worker2:~$ sudo pvs
     PV         VG          Fmt  Attr PSize   PFree
     /dev/sda3  ubuntu-vg   lvm2 a--  <46.95g   23.47g
     /dev/sdb1  longhorn_vg lvm2 a--   <3.00g 1020.00m
   ```

   

3. Resize the PV `/dev/sdb1`

   ```
       sudo pvresize /dev/sdb1
   
       ###########################
       ubuntu@worker2:~$ sudo pvs
         PV         VG          Fmt  Attr PSize   PFree
         /dev/sda3  ubuntu-vg   lvm2 a--  <46.95g   23.47g
         /dev/sdb1  longhorn_vg lvm2 a--   <3.00g 1020.00m
       ###########################
       ubuntu@worker2:~$ sudo pvresize /dev/sdb1
         Physical volume "/dev/sdb1" changed
         1 physical volume(s) resized or updated / 0 physical volume(s) not resized
       ubuntu@worker2:~$ sudo pvs
         PV         VG          Fmt  Attr PSize   PFree
         /dev/sda3  ubuntu-vg   lvm2 a--  <46.95g 23.47g
         /dev/sdb1  longhorn_vg lvm2 a--  <10.00g <8.00g
   
   ```

   

4. Extend the LVM

   ```
   sudo lvextend -r -l +100%FREE  /dev/longhorn_vg/longhorn_lv  
   ( get device name from lvdisplay)
   
   # to increase by specific size use this + is important else the existing will be replaced.
   sudo lvextend -r -L +2G  /dev/longhorn_vg/longhorn_lv 
   ```

   

5.   Resized storage now visible  on longhorn

