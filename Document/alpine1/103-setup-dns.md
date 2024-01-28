# Configure DNS server - `alpine1`
# Install bind ( DNS server) and tools dig and nslookup on alpine1.
DNS resolves Names to IP addresses. Kubetnetes will need the DNS to be closer to a production setup. Hence the requirement. This service can be skipped , but then all the connectivity will be via IP alone.

In this lab we will setup `bind` as the DNS server application.

```
#install bind
apk add bind bind-tools

# set named to start at boot
rc-update add named default

# check if the tools are installed.
dig -v
nslookup -v
```

Configure bind with a zone and resolve internet names from the configured forwarders.
```
# create named.conf file.
touch /etc/bind/named.conf

#edit named.conf file 
vi /etc/bind/named.conf

# replace or edit the file to reflect the following.

options {
     listen-on port 53 { 127.0.0.1; 192.168.100.1; };
     forwarders { 8.8.8.8; 8.8.4.4; };
     directory "/var/bind";
     dump-file "/var/bind/data/cache_dump.db";
     statistics-file "/var/bind/data/named_stats.txt";
     memstatistics-file "/var/bind/data/named_mem_stats.txt";
     allow-query { localhost; 192.168.100.0/24; };
     recursion yes;
};
zone "k8s.lab" IN {
        type master;
        file "/etc/bind/master/k8s.lab";
};
```
Next, we create the zone file. In this lab the zone name  is `k8s.lab`

```
# create folder and file
mkdir - p /etc/bind/master/ && touch /etc/bind/master/k8s.lab

# edit the file 
vi /etc/bind/master/k8s.lab
# paste following 
$TTL 38400
@ IN SOA ns.k8s.lab admin.k8s.lab. (
2       ;Serial
600     ;Refresh
300     ;Retry
60480   ;Expire
600 )   ;Negative Cache TTL

@       IN      NS      ns1.k8s.lab.
ns1     IN      A       192.168.100.1
alpine1         IN      A       192.168.100.1
k8s-ha-cluster  IN      A       192.168.100.201
loadbalancer    IN      A       192.168.100.201
master1         IN      A       192.168.100.202
master2         IN      A       192.168.100.203
master3         IN      A       192.168.100.204
worker1         IN      A       192.168.100.205
worker2         IN      A       192.168.100.206
worker3         IN      A       192.168.100.207
single          IN      A       192.168.100.199
singleubuntu    IN      A       192.168.100.198

```

Validate the bind configuration
```
# check if the formating is correct 
named-checkconf /etc/bind/named.conf

# (re)start bind service. ( the service name is 'named') 
rc-service named restart 

# ensure no errors are returned
```

Validate DNS.

```
To validate you need to run nslookup on a remote server. 
As there are no other servers setup, this can be validated when the VM's are created.

```
To ensure alpine1 resolves the FQDN's correctly ensure the following is configured 

```
# run command to check Network interface configuration
vi /etc/network/interfaces

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
        address 192.168.100.1
        netmask 255.255.255.0
## ensure the following 2 rows are added.
dns-search k8s.lab  
dns-nameservers 192.168.100.1 

```

```
#on alpine1 only.
vi /etc/resolve

nameserver 192.168.100.1
search k8s.lab

#in my case the every time the alpine1 is rebooted the values in this file get reset.
# as such the following is to set the immutable flag 

#enables readonly
chattr +i /etc/resolv.conf 

#disables readonly
chattr -i /etc/resolv.conf 

```
### Setup `alpine1` server DNS is complete.


## Next step

We will proceed with the nginx server installation 

Please continue with 
# [104-alpine1-setup-nginx](./104-alpine1-setup-nginx.md)

