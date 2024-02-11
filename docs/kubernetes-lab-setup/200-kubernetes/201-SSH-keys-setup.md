# SSH keys



When accessing Ubuntu ( or any Linux) servers, you will need to enter the username and password for every SSH session. When performing automated tasks, this can be a challenge.  SSH keys  can be used to improve this process. For our next tool Ansible ssh keys are required.

How SSH keys work?

The concept of SSH keys involve private and public keys. 

Private keys 

- are meant to be kept a secret not shared
- best to put a complex  password on the private key. 
- are stored in the `/.ssh/` folder from where the ssh client is accessed.

Public keys 

- are meant to be shared and are usually copied to the servers that are usually accessed.

run the command `ssh-keygen` on `alpine1`. 

This will create 2 files , `ubuntu-k3s-sshkey.pub` -public key  and `ubuntu-k3s-sshkey` private key . The filename can be set at the prompt. Ensure the full path is entered `/root/.ssh/ubuntu-k3s-sshkey`



```
alpine1:~# ssh-keygen

Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): /root/.ssh/ubuntu-k3s-sshkey
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/ubuntu-k3s-sshkey
Your public key has been saved in /root/.ssh/ubuntu-k3s-sshkey.pub
The key fingerprint is:
SHA256:Od1Wxp2mpTJ5YnLD7NShCJc+Y41YIlNLn2enjGZIxzU root@alpine1
The key's randomart image is:
```



#### Copy ssh keys to remote servers.

Once the key pair is generated, copy the public key to the remote Ubuntu server

The following script copies the ssh public key to the remote servers  `master1 master2 master3 worker1 worker2 worker3 xsinglenode`

```
#!/bin/sh

# SSH key file , the public key has the `.pub' extension.
ssh_key="/root/.ssh/ubuntu-k3s-sshkey.pub"

# Perform ssh-keyscan for each server and copy SSH public key
for server in loadbalancer master1 master2 master3 worker1 worker2 worker3 xsinglenode
do
    # Perform ssh-keyscan to gather SSH host key
    ssh-keyscan "$server" >> ~/.ssh/known_hosts

    # Copy SSH public key to the server
    # take note the ssh key is associated to the use 'ubuntu' in this example
    ssh-copy-id -i "$ssh_key" "ubuntu@$server"  
done

```



### Passphrase

When connecting using ssh keys, the prompt for the ssh key passphrase will be prompted for each ssh session. You can use the ssh-agent to store this passphrase

```
# start ssh-agent. 
eval $(ssh-agent) 

# add the private key using ssh-add, the passphrase will be prompted and not required to manually enter 
ssh-add /root/.ssh/ubuntu-k3s-sshkey
```



The following script adds passphrase to ssh-agent for use by ansible when connecting to remote servers

add-passphrase.sh

```

#kill all ssh-agent currently running
killall ssh-agent

# check if ssh-agent is running. 
eval $(ssh-agent) 

# add the private key using ssh-add, the passphrase will be prompted and not required to manually enter 
ssh-add /root/.ssh/ubuntu-k3s-sshkey

# list keys in memory
ssh-add -l
```



Troubleshooting points

1. Ensure only one instance of `ssh-agent` is running. You can run the following to terminate all `ssh-agent` and start a new single instance.

`killall ssh-agent`

2. Check existing ssh-agent that are running.
`ps aux | grep ssh`

