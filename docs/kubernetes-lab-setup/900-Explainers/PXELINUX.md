# `alpine1` setup and configuration.

## Setup boot files for `PXELINUX` and `OS boot`.

When a new computer starts up in the network it needs a set of boot files that provide instructions. 
In this lab setup ( an also production setups) we want to present a boot menu.
With this menu, we can then have options to perform multiple tasks. In this case we can have flavours of Operating Systems.
Including MS Windows OS deployment. This lab will review the Ubuntu OS deployment.
This 

There are 2 sets of boot files required, `PXELINUX boot files` and `Remote client OS Boot files`

### PXELINUX boot files
It is a good time to highlight there are 2 types of boot process,`BIOS` and `EFI`.
`BIOS` is for older Computers. The newer computers work with `EFI`.
This was confusing initialy as the `SYSLINUX` files actually have versions specific to `BIOS` , `EFI32` and `EFI64`. 
In `Hyper-V` when you create a VM you are given a choice of `Generation 1` or `Generation 2`. 
If you selected `Generation 1` then you need to use the `BIOS` version.
In this lab `Generation 2` was selected when the VM's are created. The BIOS version is stated here to provide this fact that could have saved me a lot of time.
The `BIOS` version is not tested.

This boot file is delivered via tftp.
Lets review the files required.


  
#### ***BIOS Core files***
```
pxelinux.0
ldlinux.c32
```
***Basic Menu***
These files are required if you want to have a menu selection.
If you don't have multple Boot options to present these files are not needed.
```
menu.c32
libutil.c32
```
***Graphics Menu***
These files are required if you want to have a menu selection but with better graphics where you can have png file as a backgroud.
If you don't have multple Boot options to present these files are not needed.

```
vesamenu.c32
libcom32.c32
```

### ***EFI64 Core files***
```
ldlinux.e64
syslinux.efi
```
***Basic Menu***
These files are required if you want to have a menu selection.
If you don't have multple Boot options to present these files are not needed.
```
menu.c32
libutil.c32
```
***Graphics Menu***
These files are required if you want to have a menu selection but with better graphics where you can have png file as a backgroud.
If you don't have multple Boot options to present these files are not needed.

```
vesamenu.c32
libcom32.c32
```

#### Where to get these files?

The files can be downloaded from
[SYSLINUX ver 6.03](https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/6.xx/syslinux-6.03.zip)
The SYSLINUX has many files, in this lab we will extract the relevant files required. This will be shared in Part 2.
### Remote client OS boot files.
The next set of Boot files are the OS boot files. For example these can be Ubuntu, Debian, Microsoft Windows boot files.
In this example we will extract the boot files from the Ubuntu ISO LiveCD.
For Linux the boot files required are. 
```
vmlinuz
initrd
```
The file name can also include the version is some cases, but the base file names will still be present.

### Completion of Boot file background.
Some background was neccasary before proceeding with the boot file preparation. Hopefully provides more clarity.



## Next step

We will proceed with the preparation of the boot files.
Please continue with 
#### 110-alpine1-setup-boot-files-part2-PXE

