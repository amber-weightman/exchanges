#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Import pre-built OpenSUSE Leap 16.0 VM into Hyper-V

.DESCRIPTION
    This script imports a pre-built OpenSUSE Leap minimal VM image into Hyper-V.
    It creates a new VM with the specified virtual disk and configures basic settings.

.PARAMETER VhdxPath
    Path to the extracted .vhdx file

.PARAMETER VMName
    Name for the VM in Hyper-V (default: OpenSUSE-Leap-16)

.PARAMETER Memory
    Amount of RAM to allocate (default: 2GB)

.PARAMETER CPUCount
    Number of virtual CPU cores (default: 2)

.PARAMETER SwitchName
    Hyper-V virtual switch name (default: "Default Switch")

.EXAMPLE
    .\01-import-vm.ps1 -VhdxPath "Z:\VMs\OpenSUSE\Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx"

.EXAMPLE
    .\01-import-vm.ps1 -VhdxPath "Z:\VMs\OpenSUSE\Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx" -Memory 4GB -CPUCount 4
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$VhdxPath,

    [Parameter(Mandatory=$false)]
    [string]$VMName = "OpenSUSE-Leap-16",

    [Parameter(Mandatory=$false)]
    [int64]$Memory = 2GB,

    [Parameter(Mandatory=$false)]
    [int]$CPUCount = 2,

    [Parameter(Mandatory=$false)]
    [string]$SwitchName = "Default Switch"
)

# Error handling
$ErrorActionPreference = "Stop"

Write-Host "`n=== OpenSUSE Leap 16.0 VM Import ===" -ForegroundColor Cyan
Write-Host "This script will import a pre-built OpenSUSE VM into Hyper-V`n" -ForegroundColor Gray

# Check if Hyper-V is available
try {
    $hypervFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
    if ($hypervFeature.State -ne "Enabled") {
        throw "Hyper-V is not enabled. Please enable it and restart your computer."
    }
} catch {
    Write-Error "Failed to check Hyper-V status: $_"
    exit 1
}

# Check if VM with same name already exists
$existingVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if ($existingVM) {
    Write-Warning "A VM named '$VMName' already exists."
    $response = Read-Host "Do you want to remove it and continue? (yes/no)"
    if ($response -eq "yes") {
        if ($existingVM.State -eq "Running") {
            Write-Host "Stopping existing VM..." -ForegroundColor Yellow
            Stop-VM -Name $VMName -Force
        }
        Write-Host "Removing existing VM..." -ForegroundColor Yellow
        Remove-VM -Name $VMName -Force
    } else {
        Write-Host "Aborted by user." -ForegroundColor Red
        exit 0
    }
}

# Get VHDX info
$vhdxInfo = Get-Item $VhdxPath
Write-Host "Source VHDX: $($vhdxInfo.FullName)" -ForegroundColor Green
Write-Host "VHDX Size: $([math]::Round($vhdxInfo.Length / 1MB, 2)) MB`n" -ForegroundColor Green

# Create VM directory
$vmPath = "C:\ProgramData\Microsoft\Windows\Hyper-V"
$vmVhdxDir = Join-Path $vmPath "Virtual Hard Disks"
$vmVhdxPath = Join-Path $vmVhdxDir "$VMName.vhdx"

Write-Host "Creating VM directory structure..." -ForegroundColor Cyan
if (!(Test-Path $vmVhdxDir)) {
    New-Item -Path $vmVhdxDir -ItemType Directory -Force | Out-Null
}

# Copy VHDX to VM directory (so original can be used as template for future VMs)
Write-Host "Copying virtual disk to Hyper-V directory..." -ForegroundColor Cyan
Write-Host "(This may take a minute...)" -ForegroundColor Gray
Copy-Item -Path $VhdxPath -Destination $vmVhdxPath -Force

# Check if specified switch exists
$switch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue
if (!$switch) {
    Write-Warning "Virtual switch '$SwitchName' not found."
    Write-Host "`nAvailable switches:" -ForegroundColor Yellow
    Get-VMSwitch | ForEach-Object { Write-Host "  - $($_.Name) ($($_.SwitchType))" }
    
    # Try to use Default Switch
    $defaultSwitch = Get-VMSwitch -Name "Default Switch" -ErrorAction SilentlyContinue
    if ($defaultSwitch) {
        Write-Host "`nUsing 'Default Switch' instead." -ForegroundColor Green
        $SwitchName = "Default Switch"
    } else {
        Write-Error "No suitable virtual switch found. Please create one or specify a valid switch name."
        exit 1
    }
}

# Create the VM
Write-Host "`nCreating Hyper-V VM..." -ForegroundColor Cyan
Write-Host "  Name: $VMName" -ForegroundColor Gray
Write-Host "  Memory: $([math]::Round($Memory / 1GB, 2)) GB" -ForegroundColor Gray
Write-Host "  CPUs: $CPUCount" -ForegroundColor Gray
Write-Host "  Switch: $SwitchName" -ForegroundColor Gray

try {
    # Create Generation 2 VM (UEFI)
    $vm = New-VM -Name $VMName `
                 -MemoryStartupBytes $Memory `
                 -VHDPath $vmVhdxPath `
                 -Generation 2 `
                 -SwitchName $SwitchName

    # Configure VM settings
    Write-Host "`nConfiguring VM settings..." -ForegroundColor Cyan
    
    # Set processor count
    Set-VMProcessor -VMName $VMName -Count $CPUCount
    
    # Enable dynamic memory
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 512MB -MaximumBytes ($Memory * 2)
    
    # Disable automatic checkpoints (can be re-enabled later if desired)
    Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $false
    
    # Enable guest services integration
    Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface"
    
    Write-Host "`n=== VM Created Successfully ===" -ForegroundColor Green
    Write-Host "`nVM Details:" -ForegroundColor Cyan
    Get-VM -Name $VMName | Format-List Name, State, CPUUsage, MemoryAssigned, Uptime, Status

    Write-Host "`n=== Default Login Credentials ===" -ForegroundColor Yellow
    Write-Host "Username: root" -ForegroundColor White
    Write-Host "Password: linux" -ForegroundColor White
    Write-Host "`n⚠️  Change the password immediately after first login!" -ForegroundColor Red

    # Ask if user wants to start the VM
    Write-Host "`n"
    $startVM = Read-Host "Do you want to start the VM now? (yes/no)"
    if ($startVM -eq "yes") {
        Write-Host "`nStarting VM..." -ForegroundColor Cyan
        Start-VM -Name $VMName
        
        Write-Host "`nWaiting for VM to boot (10 seconds)..." -ForegroundColor Gray
        Start-Sleep -Seconds 10
        
        Write-Host "`n=== VM Started ===" -ForegroundColor Green
        Write-Host "`nTo connect to the VM console, run:" -ForegroundColor Cyan
        Write-Host "  vmconnect localhost '$VMName'" -ForegroundColor White
        Write-Host "`nOr open Hyper-V Manager and double-click the VM." -ForegroundColor Gray
        
        # Try to get IP address
        Write-Host "`nAttempting to retrieve VM IP address..." -ForegroundColor Cyan
        Start-Sleep -Seconds 5
        $networkAdapter = Get-VMNetworkAdapter -VMName $VMName
        if ($networkAdapter.IPAddresses) {
            Write-Host "VM IP Address(es):" -ForegroundColor Green
            $networkAdapter.IPAddresses | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        } else {
            Write-Host "IP address not yet available. Check again in a few moments:" -ForegroundColor Yellow
            Write-Host "  Get-VMNetworkAdapter -VMName '$VMName' | Select IPAddresses" -ForegroundColor Gray
        }
    } else {
        Write-Host "`nVM created but not started." -ForegroundColor Yellow
        Write-Host "To start it later, run: Start-VM '$VMName'" -ForegroundColor Gray
    }

    Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
    Write-Host "1. Connect to VM console" -ForegroundColor White
    Write-Host "2. Login with root/linux" -ForegroundColor White
    Write-Host "3. Change root password: passwd" -ForegroundColor White
    Write-Host "4. Follow doc/02-vm-quickstart.md for initial configuration" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Error "Failed to create VM: $_"
    
    # Cleanup on failure
    if (Test-Path $vmVhdxPath) {
        Write-Host "Cleaning up..." -ForegroundColor Yellow
        Remove-Item $vmVhdxPath -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
