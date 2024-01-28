
4. install Kubelogin
```
# windows
choco install kubelogin
# Linux
https://lightrun.com/answers/azure-azure-cli-install-azure-cli-on-alpine-linux
use az cli.
apk add py3-pip
apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo make
pip install --upgrade pip
pip install azure-cli

#kubectl and kubelogin installed via
az aks install-cli
## had issues installing on alpine linux.

curl -Lo kubelogin https://github.com/Azure/kubelogin/releases/download/v0.0.34/kubelogin.zip
unzip kubelogin.zip
copy kubelogin to /usr/local/bin

```
```
reset the tmp to 2GB
alpine1:/# df -h
Filesystem                Size      Used Available Use% Mounted on
devtmpfs                 10.0M         0     10.0M   0% /dev
shm                     452.2M         0    452.2M   0% /dev/shm
/dev/sda3                47.7G      5.6G     39.7G  12% /
tmpfs                   180.9M    332.0K    180.5M   0% /run
/dev/sda1               511.0M    280.0K    510.7M   0% /boot/efi
tmpfs                   452.2M         0    452.2M   0% /tmp
cgroup_root              10.0M         0     10.0M   0% /sys/fs/cgroup
alpine1:/# vi /etc/fstab
alpine1:/# mount -o remount,size=2G,noexec,nosuid,nodev,noatime /tmp
alpine1:/# df -h
Filesystem                Size      Used Available Use% Mounted on
devtmpfs                 10.0M         0     10.0M   0% /dev
shm                     452.2M         0    452.2M   0% /dev/shm
/dev/sda3                47.7G      5.6G     39.7G  12% /
tmpfs                   180.9M    332.0K    180.5M   0% /run
/dev/sda1               511.0M    280.0K    510.7M   0% /boot/efi
tmpfs                     2.0G         0      2.0G   0% /tmp
cgroup_root              10.0M         0     10.0M   0% /sys/fs/cgroup

```