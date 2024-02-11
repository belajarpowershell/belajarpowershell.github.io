## Gotchas 

In preparing the autoinstall I had a few mistakes I made and identifying them did take alot of time. 

1. Ensure Virtual Machine specifications meet the minimum requirements.

   I had set the Memory to 512MB and enabled Dynamic memory of 512MB to 2048GB but this caused the autoinstall to crash and not complete.

2. The second issue I faced was to use the incorrect entries for `user-data-early` and `user-data-template.yaml` . Please refer to the content I used below.

`user-data-early` content.

```

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
  early-commands:
    - curl -G -o /autoinstall.yaml http://192.168.100.1/autoinstall/user-data-"$(ip a | grep ether | awk '{print $2}' | tr ':' '-')"
  locale: en_US.UTF-8
  network:
    ethernets:
      eth0:
        addresses:
        - 192.168.100.201/24
        gateway4: 192.168.100.1
        nameservers:
          addresses:
          - 192.168.100.1
          - 8.8.8.8
          search: [k8s.lab]
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
  version: 1

```

user-data-template.yaml

```

#cloud-config
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
          - 8.8.8.8
          search: [k8s.lab]
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

Here is a screenshot of the error when the `autoinstall` entry is not removed from `user-data-template.yaml`



![114-04-autoinstall-crash-autoinstall-notremoved](G:\kubernetes-lab\kubernetes-lab-setup\Document\screenshots\114-04-autoinstall-crash-autoinstall-notremoved.png)

The setup will continue but will stop, only when you press enter the script will exit.

![114-05-autoinstall-stalled](G:\kubernetes-lab\kubernetes-lab-setup\Document\screenshots\114-05-autoinstall-stalled.png)