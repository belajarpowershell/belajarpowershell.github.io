# Ansible Inventory


The main element for Ansible is the inventory. The inventory stores the list of servers that Ansible can perform actions on. 

The inventory can be in ini file or yaml  file. 

In this example we will use the inventory as an `ini` file.

Content of `hosts.ini` are a follows. 

To create the ansible folder `mkdir /srv/ansible && cd /srv/ansible`

Create the file /srv/ansible/hosts.ini 

hosts.ini

```ansible hosts.ini
[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/root/.ssh/ubuntu-k3s-sshkey
ansible_ssh_common_args=-o StrictHostKeyChecking=accept-new -o ForwardAgent=yes
k3s_cluster_name=k3s-cluster-77
k3s_single_name=k3s-single-01

[lb]
loadbalancer ansible_host=192.168.100.201

[master]
master1 ansible_host=192.168.100.202

[masterHA]
master2 ansible_host=192.168.100.203
master3 ansible_host=192.168.100.204

[worker]
worker1 ansible_host=192.168.100.205
worker2 ansible_host=192.168.100.206
worker3 ansible_host=192.168.100.207

[single]
xsinglenode ansible_host=192.168.100.199

[k3s_cluster:children]
lb
master
masterHA
worker


```

#### Ansible Playbooks

Ansible performs specific actions that are listed in a playbook. The Playbook specifies the server to execute the tasks. Each task will perform a specific function. The actual workings of Ansible is outside of the scope of this topic. But the relevant Playbooks and the steps to execute will be shared