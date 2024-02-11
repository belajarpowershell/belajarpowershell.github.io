# Configure as a Router 

In this setup, `alpine1` will function as an internet router for the servers in the  `Private 192.168.100.0/24` network.

This function is to allow the devices in the `Private 192.168.100.0/24` network to access the internet via `alpine1`. 

The configuration is simple.

ssh to `alpine1` and configure as below.
```
# paste the following in the alpine1 ssh terminal
# if you are on the Hype-V console you cannot paste the text
echo "net.ipv4.ip_forward=1" |  tee -a /etc/sysctl.conf

# reload the config using
sysctl -p

# enable IP routing on alpine1
apk add iptables

rc-update add iptables

iptables -A FORWARD -i eth1 -j ACCEPT

# eth0 is the external interface (connected to the internet)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 
/etc/init.d/iptables save

```

[Reference link to setup Alpine as a router](https://cylab.be/blog/221/a-light-nat-router-and-dhcp-server-with-alpine-linux)


### Setup alpine1 server router is completed .


## Next step

We will proceed with the DNS server installation 

Please continue with 
### 103-alpine1-setup-dns
