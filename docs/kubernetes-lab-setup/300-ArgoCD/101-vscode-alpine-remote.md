Vscode does not by default remote to alpine



Follow the steps 

https://johnsiu.com/blog/alpine-vscode/



```

vi /etc/ssh/sshd_config

AllowTcpForwarding yes
PermitTunnel       yes

```

```sh
apk add gcompat libstdc++ curl bash git
apk add zsh grep curl wget git jq git util-linux-misc procps
```



