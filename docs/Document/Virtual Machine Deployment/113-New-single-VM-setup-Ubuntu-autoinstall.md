# `alpine1` setup and configuration.

# Ubuntu Autoinstall on single VM

One other aspect I was looking at is to automate all the servers to access the configuration files that is reference with the hostname,IP,gateway and Disk config.
This way every time I have to rebuild the lab, it will be quicker. 

I understand from the Ubuntu [Automated Server installation](https://ubuntu.com/server/docs/install/autoinstall) that there is a change from version 20.04 a new method is implemented. As such most of the information gathered are from the Ubuntu forums.

### These are some references I used to prepare the autoinstall configuration
[autoinstall-quickstart](https://ubuntu.com/server/docs/install/autoinstall-quickstart)

[fetch-autoinstall-based-on-mac](https://askubuntu.com/questions/1290624/fetch-autoinstall-based-on-mac)

#### Lets get to the details

The autoinstall  requires `user-data` , `vendor-data` and `meta-data`. The `meta-data` and , `vendor-data`  are blank files. 
`user-data` however must be populated with some valid content.
In the file `/srv/tftp/efi64/pxelinux.cfg/default`, the append row below looks for the `user-data` and `meta-data` we need to ensure these file exists is referenced here.

```
`autoinstall ds=nocloud-net;s=http://192.168.100.1/autoinstalldata/`
```
Example of `user-data`. This was obtained from a manual installation of `ubuntu-20.04.6-live-server-amd64.iso`.
The file `autoinstall-user-data` is found in the folder `/var/log/installer/autoinstall-user-data`.
It is best to generate one to store the relevant configurations and then customize based on individual server requirements.

Lets create this file.

```
# this is a blank file
touch /srv/autoinstall/meta-data
touch /srv/autoinstall/vendor-data
touch /srv/autoinstall/user-data

vi /srv/autoinstall/user-data

#cloud-config
autoinstall:
  apt:
    disable_components: []
    geoip: true
    preserve_sources_list: false
    primary:
    - arches:
      - amd64
      - i386
      uri: http://my.archive.ubuntu.com/ubuntu
    - arches:
      - default
      uri: http://ports.ubuntu.com/ubuntu-ports
  drivers:
    install: false
  identity:
    hostname: master1
    password: $5$1hs/5SKiGm.zNbWk$Ap5W6Tc.YCaALtSp1INrLmYD/GIpRemhpRwtZIZCSO9
    realname: ss
    username: ubuntu
  kernel:
    package: linux-generic
  keyboard:
    layout: us
    toggle: null
    variant: ''
  locale: en_US.UTF-8
  network:
    ethernets:
      eth0:
        addresses:
        - 192.168.100.202/24
        gateway4: 192.168.100.1
        nameservers:
          addresses:
          - 192.168.100.1
          search: []
    version: 2
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: true
  storage:
    config:
    - ptable: gpt
      path: /dev/sda
      wipe: superblock
      preserve: false
      name: ''
      grub_device: false
      type: disk
      id: disk-sda
    - device: disk-sda
      size: 1127219200
      wipe: superblock
      flag: boot
      number: 1
      preserve: false
      grub_device: true
      type: partition
      id: partition-0
    - fstype: fat32
      volume: partition-0
      preserve: false
      type: format
      id: format-0
    - device: disk-sda
      size: 2147483648
      wipe: superblock
      flag: ''
      number: 2
      preserve: false
      grub_device: false
      type: partition
      id: partition-1
    - fstype: ext4
      volume: partition-1
      preserve: false
      type: format
      id: format-1
    - device: disk-sda
      size: 50410291200
      wipe: superblock
      flag: ''
      number: 3
      preserve: false
      grub_device: false
      type: partition
      id: partition-2
    - name: ubuntu-vg
      devices:
      - partition-2
      preserve: false
      type: lvm_volgroup
      id: lvm_volgroup-0
    - name: ubuntu-lv
      volgroup: lvm_volgroup-0
      size: 25203572736B
      wipe: superblock
      preserve: false
      type: lvm_partition
      id: lvm_partition-0
    - fstype: ext4
      volume: lvm_partition-0
      preserve: false
      type: format
      id: format-2
    - path: /
      device: format-2
      type: mount
      id: mount-2
    - path: /boot
      device: format-1
      type: mount
      id: mount-1
    - path: /boot/efi
      device: format-0
      type: mount
      id: mount-0
  updates: security
  version: 1

```

Generate the crypted password using the command below. The result will change with every run as there is salting present in the code.You don't have to do this if you are extracting the `user-data` from an existing installation.

```
mkpasswd --method=sha-512 123 # 123 is the password in this example

```

## Validate 

Validate `user-data` using the command below.

``` 
cloud-init schema --config-file user-data
```



We now have all the files in place for a machine to start up and autoinstall ubuntu.

With the setup in place you can now start the Virtual Machine `master1`, the network boot will present the Menu, select the option `ubuntu-iso-local` the VM will boot up with and the installation will complete without manual input.

#### Video overview on the Ubuntu Autoinstall process .
This a video covering the initial boot, Ubuntu installation and the booting to the newly installed Ubuntu.
[Autoinstall-Ubuntu-master1](https://clipchamp.com/watch/5HU0H7YUsnU)

# update to include new link

## Troubleshooting steps.
 As I performed the configuration, I faced some issues , and the following had configuration errors mostly. i.e. wrong IP, typos etc.

 - check dhcp
 Ensure the IP Addresses are assigned correctly.
 
 - Check nginx
 You can use the access log to check if a URL has been accessed. This way you can guess where the errors could be.

 - Ensure Virtual Machine specifications meet the minimum requirements.
 
 I had set the Memory to 512MB and enabled Dynamic memory of 512MB to 2048GB but this caused the autoinstall to crash and not complete.
 
 - if you choose `ubuntu-iso-remote` ensure VM has minimum 4GB of memory to load the Ubuntu OS setup. This is for the ISO to be extracted to memory.

- URL path incorrect
  Many times I found myself making simple mistakes in the path. Double check if you did the same too.

- `meta-data` and `vendor-data` not created or path configured does not have `meta-data` and `vendor-data` 

