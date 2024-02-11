

## Generate `user-data-mac-address` file.

For a Kubernetes cluster we will need multiple Virtual Machines. This will require multiple `user-data-mac-address` files to be created. Here I use PowerShell to generate the files.

To setup each Hyper-V VM with the Ubuntu Operating system we need to generate unique `user-data` files. The following script generates the script based on a working `user-data` file. This working file was extracted by installing Ubuntu from scratch with the relevant configurations. This file can be obtained from `/var/log/installer/autoinstall-user-data`. This file is renamed as `user-data-template.yaml` in this script. The script then creates new files based on the mac-address with the hostname and IP address updated.  

```powershell
# Get the directory containing the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Set the path to the script file
Set-Location $scriptDirectory
$output = "$scriptDirectory\autoinstall"
if ((Test-Path -Path $output) -ne "True") { New-Item -Path $output -ItemType Directory }

# Define a hashtable for mapping hostnames to IP addresses
$ipAddressMap = @{
    "alpine1"       = "192.168.100.1"
    "loadbalancer"  = "192.168.100.201"
    "master1"       = "192.168.100.202"
    "master2"       = "192.168.100.203"
    "master3"       = "192.168.100.204"
    "worker1"       = "192.168.100.205"
    "worker2"       = "192.168.100.206"
    "worker3"       = "192.168.100.207"
    "xsinglenode"   = "192.168.100.199"
}

# Get all virtual machines
$vms = Get-VM

# Iterate through each virtual machine
foreach ($vm in $vms) {
    # Get MAC address of the first network adapter
    $macAddress = $vm | Get-VMNetworkAdapter | Select-Object -First 1 | Select-Object -ExpandProperty MacAddress

    # Remove "k8s-" prefix from the VM name
    $vmName = $vm.Name -replace '^k8s-', ''

    # Format MAC address
    $formattedMacAddress = ($macAddress -replace '(.{2})(.{2})(.{2})(.{2})(.{2})(.{2})', '$1-$2-$3-$4-$5-$6').ToLower()

    # Get IP address from the mapping
    $ipAddress = $ipAddressMap[$vmName]

    if (-not $ipAddress) {
        Write-Host "Error: IP address not found for '$vmName'."
        continue
    }

    # Format DHCP configuration
    $dhcpConfig = @"
host $vmName {
    hardware ethernet $formattedMacAddress;
    fixed-address $ipAddress;
    option host-name "$vmName";
}
"@
    Write-Host "----------------------"
    # Output results
   # Write-Host "VM Name: $vmName"
   # Write-Host "MAC Address: $formattedMacAddress"
    Write-Host "IP Address: $ipAddress"
   # Write-Host "Server Name: $($env:COMPUTERNAME)"
    

    # Write to the CSV file
    $mac = " $vmName,$formattedMacAddress,$ipAddress"
    Write-Host $mac
    $mac | Out-File $output\mac-address-list.csv -Append

    # Create user-data files
    # Create user-data files
    $userDataFile = "$output\user-data-$formattedMacAddress"

    if (-not (Test-Path $userDataFile)) {
        # File doesn't exist, create it by copying the template
        Copy-Item -Path "user-data-template.yaml" -Destination $userDataFile
        Write-Host "File created: $userDataFile"
    }
    #this following file is to be able to identify the mac address with hostname directly from the filename
    if (-not (Test-Path $userdatafile-$vmName)) {
    # File doesn't exist, create it
    New-Item -ItemType File -Path $userdatafile-$vmName 
    Write-Host "File created: $userdatafile-$vmName"
} 
    # Get content of the template file
    $userDataContent = Get-Content -Path $userDataFile -Raw

    # Replace the placeholders with predetermined values
    $userDataContent = $userDataContent -replace 'hostname: master1', "hostname: $vmName"
    $userDataContent = $userDataContent -replace '192.168.100.202/24', "$ipAddress/24"

    # Set the modified content back to the user-data file
    Set-Content -Path $userDataFile -Value $userDataContent
    Write-Host "----------------------"

}

```

This script references 2 different files `user-data-early` and another for `user-data-template`.

These 2 files have some differences. 

`user-data`  

- On row 2 contains the entry `autoinstall:` 

- On row 28 and 29 contains the early command . This is when the file `user-data-mac-address` is downloaded to `autoinstall.yaml`

  ``` user-data-early
    early-commands:
      - curl -G -o /autoinstall.yaml http://192.168.100.1/autoinstall/user-data-"$(ip a | grep ether | awk '{print $2}' | tr ':' '-')"
  ```

 `user-data-template`

- Does not have the  `autoinstall:`  entry. Having this entry will cause the installation to fail.
- Does not have the early command to download the `user-data-template` as this was already done.



The generated files are in the subfolder  `.\autoinstall\`

![114-01-location-of-script](G:\kubernetes-lab\kubernetes-lab-setup\Document\screenshots\114-01-location-of-script.png)

From the configuration in step 112 , the Boot sequence is looking up the location. `http://192.168.100.1/autoinstall/`

This is from the following code

```
APPEND netboot=nfs boot=casper root=/dev/nfs nfsroot=192.168.100.1:/srv/isoubuntu autoinstall 
```

Copy the files created to the folder 

` /srv/autoinstall/` on the `alpine1` server. The duplicate file with the node name is workaround to show the hostname of the specific file. As I did not find away to identify the hostname using the Ubuntu autoinstall method.

![114-02-wsftp-cp-autoinstall](G:\kubernetes-lab\kubernetes-lab-setup\Document\screenshots\114-02-wsftp-cp-autoinstall.png)

If you recall from 104-setup-nginx, the folder /srv/ was exposed to be visible from `http://192.168.100.1/`. All folders created in `/srv/` will be listed via the browser.

Copy the files using WSFTP or some other method . 

Validate by browsing `http://192.168.100.1/`



![114-03-list-autoinstall-in-browser](G:\kubernetes-lab\kubernetes-lab-setup\Document\screenshots\114-03-list-autoinstall-in-browser.png)

To update Video of Script generation and the Ubuntu setup.

, `vendor-data` 

Troubleshooting tips

The MAC addresses for a newly created HyperV VM is not generated until its started at least once. 

