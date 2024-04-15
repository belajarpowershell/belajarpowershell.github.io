# Lightweight Kubernetes Setup

If you had completed the steps in [Ubuntu](/kubernetes-lab-setup/100-alpine1/113-Install-Ubuntu/) then you are ready to Install [Lightweight Kubernetes](http://k3s.io). (k3s)

Instead of installing k3s  manualy , I looked for a solution that can help expedite this process. 

Ansible was quite easy to pickup.  Ansible is not explained in detail here, but if you follow the steps, then you will be able to execute them without issues.



### Summary of the steps.

- ssh-keys 

   ssh-keys are required to allow for automated installation, without this you will have to manualy key in your password or passphrase multiple times.

   The concept of ssh-keys is simple, 2 ssh-keys are created 1 Private Key and another a Public key. 

   The Public key will need to be stored on the remote servers associated with a specific user.  Once this is done, when you connect from a central server that hosts the private ssh-key , the handshake authorizes the session without any password. 

   You can and must set up a complex  `passphrase` on the private ssh-key. This is important as if another user manages to get your private ssh-key they cannot use it without the passphrase.

   

- Ansible play books.

   Playbooks, contain the specific steps on the target server. This repository has working playbooks to setup the k3s clusters. 

   Once the setup is completed , you will have  1 x High Available k3s and 1 x singlenode k3s ready for your experiments. 




