# update DHCP options to provide PXE boot information to clients. - `alpine1`

The initial DHCP was to provide IP addresses to remote clients. 
As we now want to provide the scope options for the tftp servers with the boot file location, lets make the following changes.

Update the dhcpd.conf as follows.
```
vi /etc/dhcp/dhcpd.conf

subnet 192.168.100.0 netmask 255.255.255.0 {
   range 192.168.100.50 192.168.100.100;
   option routers 192.168.100.1;
   option domain-name-servers 192.168.100.1;
   option time-servers 192.168.100.1;
   option ntp-servers 192.168.100.1;
   # next-server 192.168.100.1; # this is typically if the tftp is on another server.
   if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00000" {
         filename "bios/pxelinux.0";
   }
   if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00007" {
         filename "efi64/syslinux.efi";
   }
   #assign IP based on MAC address
   # if you  have a need to setup DHCP for specific hosts 
   host someserver {
        hardware ethernet 00:15:5d:00:8a:3d; # change to your MAC address. 
        fixed-address 192.168.100.250;
        option host-name "someserver";
    }
}

```
Restart the dhcp service.
```
rc-service dhcpd restart
```
Validation

At this stage we cannot perform test to validate if this works. This is because we have not setup the files for the boot process.
Lets defer the test after the boot files have been setup.

## Next step

We will proceed with the DHCP setup for PXE requirements. 

Please continue with 
# [108-alpine1-DHCP-for-PXE](./108-alpine1-DHCP-for-PXE.md)

