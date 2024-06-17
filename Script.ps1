# Function to print network configuration
function Get-NetworkConfiguration {
    Write-Host "Network Configuration:"
    Get-NetAdapter | Format-Table -Property Name, InterfaceDescription, MacAddress, Status, LinkSpeed, ConnectionState
    Write-Host ""
    Get-VMSwitch | Format-Table -Property Name, SwitchType, NetAdapterInterfaceDescription
    Write-Host ""
}

# Function to list virtual machines in a private subnet
function Get-VirtualMachines {
    param (
        [string]$PrivateSubnet
    )
    Write-Host "Virtual Machines in Subnet $PrivateSubnet:"
    Get-VM | Where-Object { $_.NetworkAdapters.IPAddresses -like "$PrivateSubnet*" } | Format-Table -Property Name, State, VMId, NetworkAdapters
    Write-Host ""
}

# Function to test connectivity to a service on a virtual machine
function Test-Connectivity {
    param (
        [string]$VMName,
        [string]$Service
    )
    Write-Host "Testing connectivity to $Service on $VMName..."

    $VM = Get-VM -Name $VMName
    if ($VM) {
        $IPAddress = $VM.NetworkAdapters.IPAddresses[0]  # Assuming the VM has only one IP address
        $Endpoint = "$IPAddress/$Service"

        try {
            $result = Test-NetConnection -ComputerName $IPAddress -Port $Service -WarningAction SilentlyContinue
            if ($result.TcpTestSucceeded) {
                Write-Host "TCP connection to $Endpoint succeeded."
            } else {
                Write-Host "TCP connection to $Endpoint failed."
            }
        } catch {
            Write-Host "Failed to test connectivity to $Endpoint. Error: $_"
        }
    } else {
        Write-Host "Virtual machine $VMName not found."
    }

    Write-Host ""
}

# Main menu loop
while ($true) {
    Clear-Host
    Write-Host "Network Connectivity Testing Script"
    Write-Host "---------------------------------"
    Write-Host "1. Print Network Configuration"
    Write-Host "2. List Virtual Machines in Private Subnet"
    Write-Host "3. Test Connectivity to a Service"
    Write-Host "4. Exit"
    Write-Host ""

    $choice = Read-Host "Enter your choice (1-4):"

    switch ($choice) {
        '1' {
            Get-NetworkConfiguration
            Pause
        }
        '2' {
            $subnet = Read-Host "Enter the private subnet (e.g., 192.168.1):"
            Get-VirtualMachines -PrivateSubnet $subnet
            Pause
        }
        '3' {
            $vmName = Read-Host "Enter the name of the virtual machine:"
            $service = Read-Host "Enter the service port to test (e.g., 80 for HTTP):"
            Test-Connectivity -VMName $vmName -Service $service
            Pause
        }
        '4' {
            Write-Host "Exiting script..."
            Exit
        }
        default {
            Write-Host "Invalid choice. Please enter a number from 1 to 4."
            Pause
        }
    }
}

function Pause {
    Write-Host ""
    Write-Host "Press Enter to continue..."
    $null = Read-Host
}