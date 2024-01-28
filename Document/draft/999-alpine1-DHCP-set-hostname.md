# `alpine1` setup and configuration.

## update DHCP options to provide PXE boot information to clients.

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
host alpine1 {
    hardware ethernet 00:15:5D:00:8A:4D;
    fixed-address 192.168.100.1;
    option host-name "alpine1";
}
host loadbalancer {
    hardware ethernet 00:15:5D:00:8A:4F;
    fixed-address 192.168.100.201;
    option host-name "loadbalancer";
}
host master1 {
    hardware ethernet 00:15:5D:00:8A:50;
    fixed-address 192.168.100.202;
    option host-name "master1";
}
host master2 {
    hardware ethernet 00:15:5D:00:8A:52;
    fixed-address 192.168.100.203;
    option host-name "master2";
}
host master3 {
    hardware ethernet 00:15:5D:00:8A:53;
    fixed-address 192.168.100.204;
    option host-name "master3";
}
host worker1 {
    hardware ethernet 00:15:5D:00:8A:54;
    fixed-address 192.168.100.205;
    option host-name "worker1";
}
host worker2 {
    hardware ethernet 00:15:5D:00:8A:55;
    fixed-address 192.168.100.206;
    option host-name "worker2";
}
host worker3 {
    hardware ethernet 00:15:5D:00:8A:56;
    fixed-address 192.168.100.207;
    option host-name "worker3";
}
host xsinglenode {
    hardware ethernet 00:15:5D:00:8A:51;
    fixed-address 192.168.100.199;
    option host-name "xsinglenode";
}

}

```
Restart the dhcp service.
```
rc-service dhcpd restart
```
Vaidation
At this stage we cannot perform test to validate if this works. This is because we have not setup the files for the boot process.
Lets defer the test after the boot files have been setup.

```
alpine1         IN      A       192.168.100.1
k8s-ha-cluster  IN      A       192.168.100.201
loadbalancer    IN      A       192.168.100.201
master1         IN      A       192.168.100.202
master2         IN      A       192.168.100.203
master3         IN      A       192.168.100.204
worker1         IN      A       192.168.100.205
worker2         IN      A       192.168.100.206
worker3         IN      A       192.168.100.207

```