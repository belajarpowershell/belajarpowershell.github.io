# `alpine1` setup and configuration.

## Configure PXE configurations


Working folder.
The files for PXE will be stored in the folder `tftp` in `srv`.
 
```
mkdir -p /srv/tftp
```

In this setup syslinux was used to serve the PXE menu.

## Boot files.
When booting a Server with Linux, there are 2 files required.
`vmlinuz` and `initrd` at times the version is part of the name depending on Linux flavors

In this example boot files are retrieved from `ubuntu-20.04.6-live-server-amd64.iso`


Step 1 Download and Mount the ISO. 
```
# lets host the ISO in the folder /iso
mkdir -p /srv/tftp/iso
# Download the ISO
wget -P /srv/tftp/iso https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso

# Create mount folder 
mkdir -p /srv/isoubuntu

# mount the ISO to view contents.
mount -o loop,ro -t iso9660 /srv/tftp/iso/ubuntu-20.04.6-live-server-amd64.iso /srv/isoubuntu
# list content to validate
ls /srv/isoubuntu

```

![alt text](./screenshots/Alpine1-screenshots/mount-ubuntu-iso.png)


Step 2 Copy boot files from /srv/isoubuntu 
```
#create ubuntu folder to store the boot files.
# this way we can have boot files for multple distros if required.
mkdir -p /srv/tftp/ubuntu/casper

# copy files
cp  /srv/isoubuntu/casper/vmlinuz /srv/tftp/ubuntu/casper
cp  /srv/isoubuntu/casper/initrd /srv/tftp/ubuntu/casper
```



## PXE boot files.

Apart from the Linux boot files, we also need to have the boot files for pxelinux to function.

#### Syslinux requires the following files 
**Backgroud**

BIOS is for older Computers. The newer computers work with EFI.
This was confusing initialy as the SYSLINUX files actually have versions specific to BIOS , EFI32 EFI64. 
In HyperV when you create a VM you are given a choice of Generation 1 or Generation 2. 
If you selected Generation 1 then you need to use the BIOS version.
In this lab Generation 2 was selected. the BIOS version is stated here to provide this fact. This could have saved me a lot of time.


**BIOS Core files**

```
pxelinux.0
ldlinux.c32
```
**Basic Menu**
These files are required if you want to have a menu selection.
If you don't have multple Boot options to present these files are not needed.
```
menu.c32
libutil.c32
```
**Graphics Menu**
These files are required if you want to have a menu selection but with better graphics where you can have png file as a backgroud.
If you don't have multple Boot options to present these files are not needed.

```
vesamenu.c32
libcom32.c32
```

**EFI64 Core files**
```
ldlinux.e64
syslinux.efi
```
**Basic Menu**
These files are required if you want to have a menu selection.
If you don't have multple Boot options to present these files are not needed.
```
menu.c32
libutil.c32
```
**Graphics Menu**
These files are required if you want to have a menu selection but with better graphics where you can have png file as a backgroud.
If you don't have multple Boot options to present these files are not needed.

```
vesamenu.c32
libcom32.c32
```

#### Where to get these files?

Step 1 Download syslinux

[SYSLINUX ver 6.03 from the official site](https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.zip)

To extract the relevant files can be quite an effort to explain, I have compiled the required files.

[syslinux-6.04-pre1-PXE-specific.tar](./syslinux-files/syslinux-6.04-pre1-PXE-specific.tar)

### Boot Menu configuration 


Once we have the files in place, we can now prepare the Syslinux Boot Menu.

#### Update pxelinux.cfg/default 

```
vi /srv/tftp/efi64/pxelinux.cfg/default

DEFAULT ubuntu
TIMEOUT 50
UI vesamenu.c32
MENU RESOLUTION 1024 768
MENU BACKGROUND splash/pine-green-splash.png
MENU TITLE PXE Boot Menu


#working ISO downloaded and installer started and user-data found. 12 November 2023s
LABEL ubuntu
    MENU LABEL ubuntu
    KERNEL http://192.168.33.250/tftp/fai/ubuntu/casper/vmlinuz
    INITRD http://192.168.33.250/tftp/fai/ubuntu/casper/initrd
    append url=http://192.168.33.250/ubuntu-iso-mnt/ubuntu-20.04.6-live-server-amd64.iso cloud-config-url=/dev/null ip=dhcp fsck.mode=skip ---
	
	#working 
	append url=http://192.168.33.250/ubuntu-iso-mnt/ubuntu-20.04.6-live-server-amd64.iso autoinstall ds=nocloud-net;s=http://192.168.33.250/fai/autoinstalldata/ ip=dhcp fsck.mode=skip ---
```


```
Scratch
LABEL ubuntu
    MENU LABEL ubuntu
    KERNEL http://192.168.33.250/tftp/fai/ubuntu/casper/vmlinuz
    INITRD http://192.168.33.250/tftp/fai/ubuntu/casper/initrd
    # pass user-data in  append
    #working	
	append url=http://192.168.33.250/ubuntu-iso-mnt/ubuntu-20.04.6-live-server-amd64.iso autoinstall ds=nocloud-net;s=http://192.168.33.250/fai/autoinstalldata/ ip=dhcp fsck.mode=skip ---
	
	#scratch
    APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://10.10.2.1/ubuntu-20.10-live-server-amd64.iso autoinstall ds=nocloud-net;s=http://10.10.2.1/ubuntu-server-20.10/
	APPEND root=/dev/ram0 ramdisk_size=1500000 url=http://192.168.33.250/fai/ubuntu/ubuntu-20.04.6-live-server-amd64.iso autoinstall ds=nocloud-net;s=http://192.168.33.250/fai/autoinstalldata/
	
	append url=http://192.168.33.250/ubuntu-iso-mnt/ubuntu-20.04.6-live-server-amd64.iso autoinstall ds=nocloud-net;s=http://192.168.33.250/ks/ cloud-config-url=/dev/null ip=dhcp fsck.mode=skip ---
```