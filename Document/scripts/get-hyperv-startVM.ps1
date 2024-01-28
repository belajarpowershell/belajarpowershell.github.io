# Get the directory containing the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path


# Set the path to the script file
set-location  $scriptDirectory


# Get all virtual machines
$vms = Get-VM

# Iterate through each virtual machine
#start VM
foreach ($vm in Get-VM) {
    # Check if MAC address is 00:00:00:00:00:00
      if (($vm.State -ne 'Running') -and ($vm.Name -like "k8s-m*" -or $vm.Name -like "k8s-w*") ) {
        Write-Host $vm.Name +" Starting the VM "
        Start-VM -Name $vm.Name
        #Stop-VM -Name $vm.Name

    } 

    Write-Host "----------------------"
}

#stop VM
foreach ($vm in Get-VM) {
    # Check if MAC address is 00:00:00:00:00:00
      if (($vm.State -eq 'Running') -and ($vm.Name -like "k8s-m*" -or $vm.Name -like "k8s-w*") ) {
        Write-Host $vm.Name +" stopping the VM "
        #Start-VM -Name $vm.Name
        Stop-VM -Name $vm.Name

    } 

    Write-Host "----------------------"
}
