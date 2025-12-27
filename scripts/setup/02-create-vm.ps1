#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Create a new Hyper-V VM for OpenSUSE installation

.DESCRIPTION
    This script creates a new Hyper-V VM with an attached ISO for manual OpenSUSE installation.
    After running this script, you'll need to boot the VM and complete the installation manually.

.PARAMETER IsoPath
    Path to the OpenSUSE ISO file

.PARAMETER VMName
    Name for the VM in Hyper-V (default: OpenSUSE-Leap-16)

.PARAMETER Memory
    Amount of RAM to allocate (default: 2GB)

.PARAMETER CPUCount
    Number of virtual CPU cores (default: 2)

.PARAMETER DiskSize
    Size of the virtual hard disk in GB (default: 40GB)

.PARAMETER SwitchName
    Hyper-V virtual switch name (default: "Default Switch")

.EXAMPLE
    .\01-create-vm.ps1 -IsoPath "Z:\ISOs\Leap-16.0-offline-installer-x86_64.install.iso"

.EXAMPLE
    .\01-create-vm.ps1 -IsoPath "Z:\ISOs\Leap-16.0-offline-installer-x86_64.install.iso" -Memory 4GB -DiskSize 80
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$IsoPath,

    [Parameter(Mandatory=$false)]
    [string]$VMName = "OpenSUSE-Leap-16",

    [Parameter(Mandatory=$false)]
    [int64]$Memory = 2GB,

    [Parameter(Mandatory=$false)]
    [int]$CPUCount = 2,

    [Parameter(Mandatory=$false)]
    [int64]$DiskSize = 40GB,

    [Parameter(Mandatory=$false)]
    [string]$SwitchName = "Default Switch"
)

# Error handling
$ErrorActionPreference = "Stop"

Write-Host "`n=== OpenSUSE Leap 16.0 VM Creation ===" -ForegroundColor Cyan
Write-Host "This script will create a new Hyper-V VM for manual OpenSUSE installation`n" -ForegroundColor Gray

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

# Get ISO info
$isoInfo = Get-Item $IsoPath
Write-Host "ISO Path: $($isoInfo.FullName)" -ForegroundColor Green
Write-Host "ISO Size: $([math]::Round($isoInfo.Length / 1MB, 2)) MB`n" -ForegroundColor Green

# Set up paths
$vmPath = "C:\ProgramData\Microsoft\Windows\Hyper-V"
$vmVhdxDir = Join-Path $vmPath "Virtual Hard Disks"
$vmVhdxPath = Join-Path $vmVhdxDir "$VMName.vhdx"

Write-Host "VM will be created at: $vmPath" -ForegroundColor Gray
Write-Host "Virtual disk will be: $vmVhdxPath`n" -ForegroundColor Gray

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
Write-Host "  Disk Size: $([math]::Round($DiskSize / 1GB, 2)) GB" -ForegroundColor Gray
Write-Host "  Switch: $SwitchName" -ForegroundColor Gray

try {
    # Create new VHDX
    Write-Host "`nCreating virtual hard disk..." -ForegroundColor Cyan
    $vhdx = New-VHD -Path $vmVhdxPath -SizeBytes $DiskSize -Dynamic

    # Create Generation 2 VM (UEFI)
    Write-Host "Creating VM..." -ForegroundColor Cyan
    $vm = New-VM -Name $VMName `
                 -MemoryStartupBytes $Memory `
                 -VHDPath $vmVhdxPath `
                 -Generation 2 `
                 -SwitchName $SwitchName

    # Configure VM settings
    Write-Host "Configuring VM settings..." -ForegroundColor Cyan
    
    # Set processor count
    Set-VMProcessor -VMName $VMName -Count $CPUCount
    
    # Enable dynamic memory
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 512MB -MaximumBytes ($Memory * 2)
    
    # Add DVD drive with ISO
    Write-Host "Attaching ISO to DVD drive..." -ForegroundColor Cyan
    Add-VMDvdDrive -VMName $VMName -Path $IsoPath
    
    # Set boot order (DVD first for installation)
    $dvdDrive = Get-VMDvdDrive -VMName $VMName
    $vmFirmware = Get-VMFirmware -VMName $VMName
    Set-VMFirmware -VMName $VMName -FirstBootDevice $dvdDrive
    
    # Disable secure boot (sometimes needed for Linux)
    Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
    
    # Disable automatic checkpoints
    Set-VM -VMName $VMName -AutomaticCheckpointsEnabled $false
    
    # Enable guest services integration
    Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface"
    
    Write-Host "`n=== VM Created Successfully ===" -ForegroundColor Green
    Write-Host "`nVM Details:" -ForegroundColor Cyan
    Get-VM -Name $VMName | Format-List Name, State, CPUUsage, MemoryAssigned, Uptime, Status

    Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
    Write-Host "1. Start the VM: Start-VM '$VMName'" -ForegroundColor White
    Write-Host "2. Connect to VM console: vmconnect localhost '$VMName'" -ForegroundColor White
    Write-Host "3. Follow the installation guide in doc/02-vm-setup.md" -ForegroundColor White
    Write-Host "4. Complete OpenSUSE installation manually" -ForegroundColor White
    
    # Ask if user wants to start the VM and open console
    Write-Host "`n"
    $startVM = Read-Host "Do you want to start the VM and open the console now? (yes/no)"
    if ($startVM -eq "yes") {
        Write-Host "`nStarting VM..." -ForegroundColor Cyan
        Start-VM -Name $VMName
        
        Write-Host "Opening VM console..." -ForegroundColor Cyan
        Start-Sleep -Seconds 2
        vmconnect localhost $VMName
        
        Write-Host "`n=== VM Started ===" -ForegroundColor Green
        Write-Host "Follow the on-screen installation wizard." -ForegroundColor White
        Write-Host "Refer to doc/02-vm-setup.md for detailed installation steps." -ForegroundColor White
    } else {
        Write-Host "`nVM created but not started." -ForegroundColor Yellow
        Write-Host "When ready, run: Start-VM '$VMName'" -ForegroundColor Gray
        Write-Host "Then connect: vmconnect localhost '$VMName'" -ForegroundColor Gray
    }
    
    Write-Host ""

} catch {
    Write-Error "Failed to create VM: $_"
    
    # Cleanup on failure
    if (Test-Path $vmVhdxPath) {
        Write-Host "Cleaning up..." -ForegroundColor Yellow
        Remove-Item $vmVhdxPath -Force -ErrorAction SilentlyContinue
    }
    if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
        Remove-VM -Name $VMName -Force -ErrorAction SilentlyContinue
    }
    exit 1
}
