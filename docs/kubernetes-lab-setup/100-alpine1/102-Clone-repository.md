# Clone-repository

In this step we will download the files required to setup the various services. We now clone the repository to `ansible1`.

#####  This script is to download the files  from the Repository https://github.com/belajarpowershell/kubernetes-lab

```
# Step 1 clone the repository
# Step 2 run the script `alpine1-first-run.sh`
# This script will perform the following
# - move the `srv` from git folder "kubernetes-lab/" to "/srv" 
# - enable the community repository to install ansible
# - install Ansible using run `apk add ansible`

# install git 
apk add git

# clone the repository
git clone https://github.com/belajarpowershell/kubernetes-lab.git

# change folder
cd kubernetes-lab


# change the script to executable
chmod +x alpine1-first-run.sh


#run the script 
./alpine1-first-run.sh

# this script will perform the following
# 1. copy the `srv` from git folder "kubernetes-lab/" to "/srv" 
# 2. Install Ansible
# 3. Download the Ubuntu installer to `/srv/tftp/iso`

# files `kubernetes-lab/srv` folder is now copied to /srv
# this is important as the files required for the setup must be located at `/srv/`

```



