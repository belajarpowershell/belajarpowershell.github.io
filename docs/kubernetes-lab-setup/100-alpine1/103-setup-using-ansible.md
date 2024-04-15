# Setup services using Ansible

Setting up the various services for automation is time consuming and possible prone to errors.

Using Ansible, I was able to reduce the time it took deploy the services required. 

Here we use the playbook with the complete steps in `alpine-services.yaml`. In `103-setup-using-ansible-manual` the individual services are separated. 

#### Ansible Playbook execution  

Change directory to `/srv/ansible/playbook-alpine1`

```
cd /srv/ansible/playbook-alpine1
```

Execute the playbook run from `/srv/ansible/playbook-alpine1`

```
ansible-playbook alpine-services.yaml
```



Once the scripts are completed the following would have been setup

1. 
