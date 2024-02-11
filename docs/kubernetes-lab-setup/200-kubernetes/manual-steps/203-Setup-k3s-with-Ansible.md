# Ansible Playbook steps



Setting up a single node k3s is very quick , takes about 2-3 minutes to setup. Setting up a k3s High Availability cluster is more complex.

Having the goal of getting a Kubernetes Lab setup quickly, the best option I had was to use Ansible.  I have playbooks to setup one k3s High Availability Clusters and a single node k3s. Managing the k3s is best to be remote, to accommodate that, made the `alpine1` the kubectl management server. 

The most challenging task I faced when I started with kubernetes was the KUBECONFIG . Once I had this working learning the other tasks were that much easier. The Playbook and bash scripts make this easier for you.  

The following describes the relevant files in the `ansible` folder. That will help with the setup of the 2 k3s clusters mentioned.





####Ansible folder content

Folder `ansible`

Prepare / run this first 

hosts.ini

> - contains the list of servers and the various roles they have.
> - The Ansible playbook references this file on the servers to perform the tasks on.

add-passphrase.sh

> - The script to store the ssh-key passphrase so it can be referenced when Ansible connects to the remote servers.
> - Run this script once before running the playbooks.

copy-ssh-key.sh

> - The ssh public key must be copied to the remote servers once. 
> - This script automates the task .



Folder `playbook`

Run the ansible playbook in the sequence listed. The description of the tasks performed are listed below. 

00-apt-update.yml

> - Performs apt-update on all Ubuntu servers
> - Installs kubectl on `alpine1`



```
execute the playbook run from `/srv/ansible`
ansible-playbook 00-apt-update.yml  --user ubuntu --ask-become-pass  -i hosts.ini

```



01-k3s-loadbalancer-setup.yml

> - Installs Docker  and Nginx on the Loadbalancer

```
execute the playbook run from `/srv/ansible`
ansible-playbook 01-k3s-loadbalancer-setup.yml --user ubuntu --ask-become-pass  -i hosts.ini
```



j2\nginx.conf.j2

> - When the load balancer is setup with `nginx` the required configuration for the loadbalancer is generated from the Jinja2 (j2) script.



02-k3s-HA-setup.yml

> - Installs k3s server on master1,master2 and master3
> - Installs k3s agent on worker1,worker2,worker3.

```
execute the playbook run from `/srv/ansible`
ansible-playbook 02-k3s-HA-setup.yml --user ubuntu --ask-become-pass  -i hosts.ini
```



02z-k3s-copy-kubeconfig.yml

> - Copies kubeconfig files from cluster to  `ansible1` in the folder `/root/.kube./clusters/` to remotely manage the k3s cluster
> - The kubeconfig file also updates the names to be specific to the cluster.
> - Updates the localhost entries to `Loadbalancer`  

```
execute the playbook run from `/srv/ansible`
ansible-playbook 02z-k3s-copy-kubeconfig.yml --user ubuntu --ask-become-pass  -i hosts.ini
```



03-k3s-single-node-setup.yml

> - Installs k3s as a single instance.

```
execute the playbook run from `/srv/ansible`
ansible-playbook 03-k3s-single-node-setup.yml --user ubuntu --ask-become-pass  -i hosts.ini
```



03z-k3s-copy-kubeconfig-single.yml

> - Copies kubeconfig files from the single node k3s to  `ansible1`  in the folder `/root/.kube./clusters/` to remotely manage the k3s cluster
> - The kubeconfig file also updates the names to be specific to the cluster.
> - Updates the localhost entries to `Loadbalancer`  

```
execute the playbook run from `/srv/ansible`
ansible-playbook 03z-k3s-copy-kubeconfig-single.yml --user ubuntu --ask-become-pass  -i hosts.ini
```



98-k3s-remove-all.yml

> - If there is a need to remove the k3s installations this playbook removes the k3s from  `master1,master2 ,master3,worker1,worker2,worker3,xsinglenode`

```
execute the playbook run from `/srv/ansible`
ansible-playbook 98-k3s-remove-all.yml --user ubuntu --ask-become-pass  -i hosts.ini
```



ansible-vars.yml

> - The ansible variables are stored in this file. 
> - In this example the file stores the various setup commands to install `k3s' for the different roles. 



#### Kubeconfig on `alpine1`

Once the scripts `02z-k3s-copy-kubeconfig.yml` and `03z-k3s-copy-kubeconfig-single.yml` are completed. The playbook copy the remote kubeconfig files from the remote servers . The files will be stored in `/root/.kube/clusters`  folder. 

 We now need to have the KUBECONFIG setup on `alpine` . The following will merge all `*.yaml` files in `/root/.kube/clusters`

```
 export KUBECONFIG=$(for YAML in $(find ${HOME}/.kube/clusters -name '*.yaml') ; do echo -n ":${YAML}"; done)
```

This is not permanent . Do check how you can make this permanent after logout from the session. 

#### `kubectl` basic commands

Running some basic `kubectl` commands.

List of contexts. 

```
(1) kubectl config get-contexts.
```

Change context

```
(2) and (4) kubectl config use-context <context name>
```

List kubernetes nodes

```
(3) and (4) kubectl get nodes
```



Here is a screenshot that will provide some perspective

![202-01-kubectl-example](./../../screenshots/202-01-kubectl-example.png)

2. 
