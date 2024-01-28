# Install and Configure tftpd - `alpine1`
tftp is required for PXELINUX boot setup.
This is how the initial boot files are retrieved from the remote client.
```
# create directories
mkdir /srv/tftp/

#install tftpd 
apk update
apk add tftp-hpa

# set nginx to start at boot
rc-update add in.tftpd

# Update in.tftpd configuration
vi /etc/conf.d/in.tftpd
  #change or update row to reflect the path /srv/tftp/
  INTFTPD_PATH="/srv/tftp/"

#check in.tftpd  service status
rc-service in.tftpd status

#Start service now
rc-service in.tftpd start
```

The path `/srv/tftp/` is important to note as the subsequent configuration will use this folder as root.

## Next step

We will proceed with the cloud-init installation 

Please continue with 
# [107-alpine1-cloud-init](./107-alpine1-cloud-init.md)

