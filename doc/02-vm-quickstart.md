# VM Quick-Start Setup: Import Pre-built OpenSUSE VM

> **📚 Official Documentation:**
> - [OpenSUSE Leap 16.0 Documentation](https://doc.opensuse.org/documentation/leap/archive/16.0/)
> - [OpenSUSE Pre-built Images](https://get.opensuse.org/leap/16.0/?type=server#download)
> - [Microsoft Hyper-V Documentation](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/)

This guide uses a **pre-built minimal VM image** to get you up and running in minutes without manual OS installation.

## Why Pre-built VM?

Since the goal is to **learn how to operate existing systems** (not master OS installation), using a pre-built VM lets you:
- Skip manual installation steps
- Get to actual learning faster
- Smaller download (192 MB vs 4+ GB ISO)
- Boot to a working system immediately

## Choose Your Hypervisor

[OpenSUSE](https://get.opensuse.org/leap/16.0/?type=server#download) provides pre-built images for multiple hypervisors:

| Hypervisor | Image File | Size | This Guide |
|------------|------------|------|------------|
| **Hyper-V** | `.vhdx.xz` | 191.8 MB | ✅ Covered here |
| **VMware** | `.vmdk` | 730.2 MB | ⚠️ Not covered |
| **KVM/XEN** | `.qcow2` | 276.6 MB | ⚠️ Not covered |

**This guide assumes Hyper-V.** If you're using VMware or another hypervisor, the general steps are similar but import procedures differ.

## Prerequisites

Before proceeding, ensure:
- [ ] You've completed [Prerequisites](01-prerequisites.md) (Hyper-V enabled, running as Administrator)
- [ ] You have internet connection for download
- [ ] At least 10 GB free disk space (VM will expand as you use it)

## Step 1: Download Pre-built VM

**Download URL:**
```
https://download.opensuse.org/distribution/leap/16.0/appliances/Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx.xz
```

**Using PowerShell (recommended):**

```powershell
# Create directory for VM images
New-Item -Path "Z:\VMs\OpenSUSE" -ItemType Directory -Force

# Download the pre-built Hyper-V image (~192 MB)
$VmUrl = "https://download.opensuse.org/distribution/leap/16.0/appliances/Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx.xz"
$VmArchive = "Z:\VMs\OpenSUSE\Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx.xz"

Start-BitsTransfer -Source $VmUrl -Destination $VmArchive -Description "Downloading OpenSUSE Leap 16.0 Minimal VM" -DisplayName "OpenSUSE VM"
```

**Alternative: Download via browser:**
- Visit: https://get.opensuse.org/leap/16.0/?type=server#download
- Scroll to "Minimal Virtual Machine"
- Click "MS HyperV image"
- Save to: `Z:\VMs\OpenSUSE\Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx.xz`

## Step 2: Extract the Virtual Disk

The downloaded file is compressed (`.xz` format) and needs to be extracted.

**Option A: Using 7-Zip (if installed):**
```powershell
# If you have 7-Zip installed
& "C:\Program Files\7-Zip\7z.exe" x "Z:\VMs\OpenSUSE\Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx.xz" -o"Z:\VMs\OpenSUSE\"
```

**Option B: Using Windows built-in tar (Windows 10+):**
```powershell
# Windows 10/11 includes tar which supports .xz
cd Z:\VMs\OpenSUSE
tar -xf Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx.xz
```

**Result:** You should now have `Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx` (approximately 2-3 GB extracted)

## Step 3: Import VM into Hyper-V

Now we'll run the import script to create and configure the VM in Hyper-V.

**Run the import script:**
```powershell
.\scripts\setup\01-import-vm.ps1 -VhdxPath "Z:\VMs\OpenSUSE\Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx"
```

**What the script does:**
- Creates a new Hyper-V VM named "OpenSUSE-Leap-16"
- Configures 2 CPU cores and 2 GB RAM (adjustable)
- Attaches the extracted virtual disk
- Configures network adapter (Default Switch)
- Sets up Generation 2 VM (UEFI boot)
- Starts the VM

**Script parameters (optional):**
```powershell
# Customize VM resources
.\scripts\setup\01-import-vm.ps1 `
    -VhdxPath "Z:\VMs\OpenSUSE\Leap-16.0-Minimal-VM.x86_64-MS-HyperV.vhdx" `
    -VMName "MySUSEServer" `
    -Memory 4GB `
    -CPUCount 4
```

## Step 4: Connect to VM Console

After the script completes, connect to the VM:

**Option 1: Via Hyper-V Manager:**
1. Open **Hyper-V Manager**
2. Find "OpenSUSE-Leap-16" in the VM list
3. Right-click → **Connect**
4. Click **Start** if VM is not already running

**Option 2: Via PowerShell:**
```powershell
# Open VM connection window
vmconnect localhost "OpenSUSE-Leap-16"
```

## Step 5: First Login

The pre-built VM comes with default credentials:

```
Username: root
Password: linux
```

**⚠️ Security Note:** You MUST change this password immediately after first login.

**Change root password:**
```bash
passwd
# Enter new password twice
```

## Step 6: Initial Configuration

After logging in, perform basic setup:

**1. Update hostname:**
```bash
hostnamectl set-hostname suse-server
```

**2. Check network connectivity:**
```bash
ip addr show
ping -c 3 google.com
```

**3. Update system packages:**
```bash
zypper refresh
zypper update -y
```

**4. Install essential tools:**
```bash
zypper install -y vim openssh sudo
```

**5. Enable SSH (for remote access):**
```bash
systemctl enable sshd
systemctl start sshd
```

## Step 7: Create Regular User

Don't use root for daily tasks - create a regular user:

```bash
# Create new user (replace 'yourusername' with your name)
useradd -m -G wheel yourusername

# Set password
passwd yourusername

# Allow wheel group to use sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/wheel
```

## Next Steps

Now that your VM is functional with SSH enabled, proceed to:

**[SSH Access](03-ssh-access.md)** - Configure SSH keys and connect from Windows or VS Code

## Troubleshooting

**VM won't start:**
- Check Hyper-V is enabled: `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All`
- Verify virtualization enabled in BIOS
- Check VM state: `Get-VM "OpenSUSE-Leap-16"`

**Can't connect to VM console:**
- Ensure VM is running: `Start-VM "OpenSUSE-Leap-16"`
- Check VM status: `Get-VM "OpenSUSE-Leap-16" | Select Name, State`

**Network not working in VM:**
- Check Default Switch exists: `Get-VMSwitch`
- Verify VM network adapter: `Get-VMNetworkAdapter -VMName "OpenSUSE-Leap-16"`
- Inside VM: `ip addr show` and `systemctl status network`

**Login credentials don't work:**
- Default: `root` / `linux`
- Try from VM console (not SSH) first
- If still failing, you may need to reset via recovery mode

## VM Management Commands

**Useful Hyper-V commands:**
```powershell
# Start/Stop VM
Start-VM "OpenSUSE-Leap-16"
Stop-VM "OpenSUSE-Leap-16"

# Check VM status
Get-VM "OpenSUSE-Leap-16"

# Create checkpoint (snapshot)
Checkpoint-VM "OpenSUSE-Leap-16" -SnapshotName "Initial-Setup"

# Restore checkpoint
Restore-VMSnapshot -Name "Initial-Setup" -VMName "OpenSUSE-Leap-16" -Confirm:$false

# Get VM IP address
Get-VMNetworkAdapter -VMName "OpenSUSE-Leap-16" | Select IPAddresses
```
