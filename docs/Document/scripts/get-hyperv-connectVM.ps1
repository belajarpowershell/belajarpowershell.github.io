# Get the directory containing the script
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path


# Set the path to the script file
set-location  $scriptDirectory
# Get all virtual machines
$vms = Get-VM

# Iterate through each virtual machine
foreach ($vm in $vms) {
    # Check if MAC address is 00:00:00:00:00:00
      if ($vm.State -ne 'Running') {
        Write-Host "Starting the VM $vm.Name "
        start-VM -Name $vm.Name

    } else
    {$vm.Name+" already started"}

    Write-Host "----------------------"
}


function Connect-VM {
	param(
		[Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
		[String[]]$ComputerName
	)
	PROCESS {
		foreach ($name in $computername) {
			.\vmconnect.exe localhost $name
            
		}
	}
}

(get-vm | where { $_.State -ne "Off" }).name |Connect-VM



