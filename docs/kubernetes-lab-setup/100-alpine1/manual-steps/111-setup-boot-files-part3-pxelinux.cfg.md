# Configure PXE Boot menu

Configure the boot menu `pxelinux.cfg/default`
The final piece is to prepare the boot menu to load and present a selection that will install the Ubuntu OS.

This file is already with the configuration below.

Validate the file content of `pxelinux.cfg/default` matches the code below.
```
vi /srv/tftp/efi64/pxelinux.cfg/default

DEFAULT Bootlocal
TIMEOUT 50
UI vesamenu.c32
MENU RESOLUTION 1024 768
MENU BACKGROUND splash/pine-green-splash.png
MENU TITLE PXE Boot Menu


LABEL ubuntu-iso-remote #iso downloaded from http. Requires 4GB of Memory
    MENU LABEL ubuntu-iso-remote (iso downloaded - 4GB Memory)
    KERNEL http://192.168.100.1/tftp/ubuntu/casper/vmlinuz
    INITRD http://192.168.100.1/tftp/ubuntu/casper/initrd
    append url=http://192.168.100.1/tftp/iso/ubuntu-20.04.6-live-server-amd64.iso autoinstall ds=nocloud-net;s=http://192.168.100.1/autoinstall/ ip=dhcp fsck.mode=skip ---

LABEL ubuntu-DVD-local (Ubuntu  DVD locally mounted - 1GB Memory)
    MENU LABEL ubuntu-iso-local (iso locally mounted 1GB of Memory)
    KERNEL http://192.168.100.1/tftp/ubuntu/casper/vmlinuz
    INITRD http://192.168.100.1/tftp/ubuntu/casper/initrd
    APPEND autoinstall ds=nocloud-net;s=http://192.168.100.1/autoinstall/ ip=dhcp fsck.mode=skip ---

LABEL ubuntu-nfs-boot (Ubuntu  iso mounted on nfs - 1GB Memory)
    MENU LABEL ubuntu-iso-local (iso locally mounted 1GB of Memory)
    KERNEL http://192.168.100.1/tftp/ubuntu/casper/vmlinuz
    INITRD http://192.168.100.1/tftp/ubuntu/casper/initrd
    APPEND netboot=nfs boot=casper root=/dev/nfs nfsroot=192.168.100.1:/srv/isoubuntu autoinstall ds=nocloud-net;s=http://192.168.100.1/autoinstall/ ip=dhcp fsck.mode=skip ---

LABEL Bootlocal
	MENU LABEL Bootlocal 
	LOCALBOOT 0

```
With the above configuration in place, a remote server in the `Private 192.168.100.0/24` network that has Network boot configured will be able to boot successfully. 

### What happens next?
When the remote client boots, it will get the DHCP options for the `tftp` server. The `syslinux.efi` will load and then present the boot menu. Choosing either option will present with the Ubuntu install window. The usual process to setup can now continue.

### Lessons Learnt

 As I performed the configuration, I faced some issues , and the following had configuration errors mostly. i.e. wrong IP, typos etc.
 - Check DHCP 
 Check the logs to see if the IP is being assigned. If it does not it could be a network related configuration.
 - Check nginx
 If a URL is part of the process, check the `nginx` access logs for reference to queries to the specific url.
 - ensure VM has minimum 4GB of memory to load the Ubuntu OS setup. This is for the ISO to be extracted to memory.
- URL path incorrect.
- the selection of `ubuntu-iso-local`` is actualy looking at for the ISO to be mounted locally. The files are not loaded from `nfs`. 

## Next step

The PXE boot to install Ubuntu is now complete. 
If you are looking to automate the entries for the Ubuntu installation, the next step will review the relevant points.

### 113-New-VM-setup-Ubuntu-autoinstall
