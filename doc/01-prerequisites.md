# Prerequisites for SUSE Linux Server VM Setup

This document covers what you need before running the automated VM creation scripts.

## System Requirements

### Windows Edition
You need **Windows 10/11 Pro, Enterprise, or Education** for Hyper-V support.

To check your edition:
```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
```

### Hardware Requirements
**Minimum for VM:**
- 2 CPU cores (4 recommended)
- 4 GB RAM (8 GB recommended)
- 40 GB disk space (80 GB+ recommended for media server later)
- Virtualization support in CPU (Intel VT-x or AMD-V)

**Check if virtualization is enabled:**
```powershell
Get-ComputerInfo | Select-Object HyperVisorPresent, HyperVRequirementVirtualizationFirmwareEnabled
```

Expected output:
```
HyperVisorPresent                            : True
HyperVRequirementVirtualizationFirmwareEnabled : True
```

If `HyperVisorPresent` is `False`, Hyper-V needs to be enabled (see below).

If `VirtualizationFirmwareEnabled` is `False`, you need to enable virtualization in BIOS/UEFI:
- Restart computer
- Enter BIOS/UEFI (usually F2, F10, Del, or Esc during boot)
- Look for "Intel VT-x", "AMD-V", or "Virtualization Technology"
- Enable it and save

## Enable Hyper-V

**Check if Hyper-V is already enabled:**
```powershell
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```

**If not enabled, run as Administrator:**
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
```

Then restart your computer.


## Next Steps

Once all prerequisites are met:

**Recommended - Quick Start:**
- Follow **[VM Quick Start Guide](02-vm-quickstart.md)** to download and import the pre-built VM (fastest path)

**Alternative - Manual Installation:**
- Follow **[VM Setup Guide](02-vm-setup.md)** to create and configure a custom VM
