# VS Code remote to Alpine nodes

With default configurations, VS Code cannot to remote host via `Remote - SSH`

This blog provided some input on how to get this workind.

Follow the steps provided here [Alpine-VSCode](https://johnsiu.com/blog/alpine-vscode/)



In addtion make the following changes.

```
# on alpine1

vi /etc/ssh/sshd_config

AllowTcpForwarding yes
PermitTunnel       yes

```

```sh
#on alpine1 install the following add on 
apk add gcompat libstdc++ curl bash git
apk add zsh grep curl wget git jq git util-linux-misc procps
```



Once the above is completed, you would be able to SSH to `alpine1`



