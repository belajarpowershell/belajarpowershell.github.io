# Hyper-V Virtual Machine creation

As part of a Lab setup, I expect to create and destroy the VM's regularly.
To reduce the pain of recreating manually, I use a PowerShell script to create the Hyper-V VM's with certain specifications.

To use this script, you must have already have a working Hyper-V. You can refer to this link [Enable Hyper-V on Windows 11](https://techcommunity.microsoft.com/t5/educator-developer-blog/step-by-step-enabling-hyper-v-for-use-on-windows-11/ba-p/3745905)

To use this script:-
- run `Powershell ISE` as Administrator. ( Right click `PowerShell ISE` select `Run as Administrator`)

- Open the file `G:\kubernetes-lab\srv\scripts\001-Kubernetes-Create-HyperV-VM copy.csv`

  Click on the `Green Play` button, this will execute the script.

// method to access Video-- QR code?

[Here is a video that might help](https://clipchamp.com/watch/EYzyfDZUGRv)

#### Lessons Learned

1. Hyper-V VM Memory needs to be at minimum 1GB. Any lower the Ubuntu will fail to install. Wasted a few days to catch this. 
2. If you are using the download ISO to memory then you need to have a minimum of 4GB on the Hyper-V VM  to load the ISO to memory. 

#### Once the Virtual Machines are created proceed to `100-alpine1-setup` steps.
