# Get the directory containing the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Set the path to the script file
Set-Location $scriptDirectory
$output = "$scriptDirectory\autoinstall"
if ((Test-Path -Path $output) -ne "True") { New-Item -Path $output -ItemType Directory }

# Define a hashtable for mapping hostnames to IP addresses
$ipAddressMap = @{
    "alpine1"       = "192.168.100.201"
    "loadbalancer"  = "192.168.100.202"
    "master1"       = "192.168.100.203"
    "master2"       = "192.168.100.204"
    "master3"       = "192.168.100.205"
    "worker1"       = "192.168.100.206"
    "worker2"       = "192.168.100.207"
    "worker3"       = "192.168.100.208"
    "xsinglenode"   = "192.168.100.209"
    "xsingleubuntu" = "192.168.100.210"
}

# Get all virtual machines
$vms = Get-VM

# the following stesp is to create individual user-data-mac-address files for each server to be setup.

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
   
   #The following steps are to create the user-data , meta-data and vendor-data files required by autoinstall.
    # Create the file user-data in the autoinstall path
    if (-not (Test-Path $output\user-data)) {
        # File doesn't exist, create it by copying the template
        Copy-Item -Path "user-data-early" -Destination $output\user-data
        Write-Host "File created: $output\user-data"
    }

    # Create the file vendor-data in the autoinstall path
    if (-not (Test-Path $output\vendor-data)) {
        # File doesn't exist, create it by copying the template
        New-Item -ItemType File  -Path $output\vendor-data
        Write-Host "File created: $output\vendor-data"
    }
    # Create the file meta-data in the autoinstall path
    if (-not (Test-Path $output\meta-data)) {
        # File doesn't exist, create it by copying the template
        New-Item -ItemType File  -Path $output\meta-data
        Write-Host "File created: $output\meta-data"
    }