# Setup services Manual Steps
Setting up the various services for automation is time consuming and possible prone to errors.

Using Ansible, I was able to reduce the time it too deploy the services required. 

Here we use the playbook with the several playbooks as below. 

 In `103-setup-using-ansible` the steps are combined and implemented in a single command. The individual steps will be helpful for troubleshooting or if there is a need to change selected configuration.



#### Ansible Playbook execution  

Change directory to `/srv/ansible/playbook-alpine1`

```
cd /srv/ansible/playbook-alpine1
```

Execute the playbook run from `/srv/ansible/playbook-alpine1`

#### 101 DHCP server Setup 

```
ansible-playbook 101-DHCP-server.yaml
```

#### 102 Setup `alpine1` as a router

```
ansible-playbook 102-setup-router.yaml
```

#### 103 DNS Setup 

```
ansible-playbook 103-setup-DNS.yaml
```

#### 104 Nginx Setup

```
ansible-playbook 104-setup-nginx.yaml
```

#### 105 NFS  Setup

```
ansible-playbook 105-nfs.yaml
```

#### 106 Cloud-init Setup

```
ansible-playbook 106-cloud-init.yaml
```

#### 108 DHCP for PXE Setup

```
ansible-playbook 108-DHCP-for-PXE.yaml
```

#### 110 Boot file setup.

```
ansible-playbook 110-setup-boot-files-part2-OS.yaml
```

