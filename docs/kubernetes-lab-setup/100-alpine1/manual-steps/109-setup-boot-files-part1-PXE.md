# Setup boot files for PXELINUX

The boot files are separated by the type of Boot process `BIOS` and `EFI`
Take note the files while have duplicate names, there are separate versions for `BIOS` and `EFI`.

If you had followed the steps from 000-ReadMeFirst, you would already have the following files available.

## TFTP Directory and content

- **(/srv/tftp/bios)**
`pxelinux.0`
`ldlinux.c32`
`menu.c32`
`libutil.c32`
`vesamenu.c32`
`libcom32.c32`
`pxelinux.cfg\default`
- **(/srv/tftp/efi64)**
`ldlinux.e64`
`syslinux.efi`
`menu.c32`
`libutil.c32`
`vesamenu.c32`
`libcom32.c32`
`pxelinux.cfg\default`




## Next step

We will proceed with the preparation of the OS boot files.
Continue with 
### 110-setup-boot-files-part2-OS
