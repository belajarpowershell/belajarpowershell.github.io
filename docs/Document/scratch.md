# nfs for ubuntu
vi  /etc/exports
/srv/fai/ubuntu 192.168.33.250/24(async,ro,no_subtree_check)


#

mount -r ~/Downloads/ubuntu-22.10-live-server-amd64.iso /mnt

#
vi /etc/ssh/sshd_config


# fix up down arrow in vi
~/.vimrc
set nocompatible


###
user-data by mac-address
https://askubuntu.com/questions/1290624/fetch-autoinstall-based-on-mac
  keyboard:
    layout: us
    toggle: null
    variant: ''
  early-commands:
    - curl -G -o /autoinstall.yaml http://192.168.100.1/autoinstall/user-data -d "mac=$(ip a | grep ether | cut -d ' ' -f6)"


https://askubuntu.com/questions/1309505/choose-autoinstall-config-by-bios-serial-or-mac
extract user-data based on mac addrress to update autoinstall.yaml.
This way each VM can have its own configuration.
early-commands:
    - cp "/cdrom/nocloud/install-configs/$(dmidecode -s system-serial-number)" /autoinstall.yaml

    