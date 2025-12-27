# VM Setup: Download SUSE Linux Server & Create VM

> **📚 Official Documentation:**
> - [OpenSUSE Leap 16.0 Documentation](https://doc.opensuse.org/documentation/leap/archive/16.0/)
> - [OpenSUSE Installation Guide](https://doc.opensuse.org/documentation/leap/archive/16.0/startup/html/book-startup/part-basics.html)
> - [OpenSUSE Downloads](https://get.opensuse.org/leap/16.0/)
> - [Microsoft Hyper-V Documentation](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/)
>
> If you encounter issues not covered in this guide, refer to the official documentation above or ask Copilot for help.

## Download SUSE Linux Server

> **About OS selection:** This project uses OpenSUSE Leap 16.0 (latest stable). While enterprises typically run older versions (SLES 15 series), the fundamental skills learned are 100% transferable. For background on distribution choices, see [Linux SUSE Distributions](resources/linux-distro.md).

> **⚡ Quick Start Available:** For the fastest setup, see the **[Quick Start Guide](02-quickstart.md)** which uses a pre-built VM image (~192 MB download, ready in minutes). The instructions below are for traditional ISO installation.

**OpenSUSE Leap 16.0:**
- Download: [OpenSUSE Leap 16.0](https://get.opensuse.org/leap/16.0/)
- Choose: **Offline Image** - approximately 4.2 GB
- No registration required

**SUSE Linux Enterprise Server (SLES) - alternative:**
- For enterprise-exact distribution, see [SLES Developer Setup](resources/linux-distro.md)
- Includes instructions for free developer licenses and evaluation downloads
- Nearly identical to OpenSUSE for learning purposes

### Download Instructions

**1. Create a directory for ISOs:**
```powershell
New-Item -Path "Z:\ISOs" -ItemType Directory -Force
```

**2. Download using PowerShell (recommended):**
```powershell
# Download OpenSUSE Leap 16.0 (this will take a while - ~4.2 GB)
$IsoUrl = "https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-offline-installer-x86_64.install.iso"
$IsoPath = "Z:\ISOs\Leap-16.0-offline-installer-x86_64.install.iso"

# Download with progress bar
Start-BitsTransfer -Source $IsoUrl -Destination $IsoPath -Description "Downloading OpenSUSE Leap 16.0" -DisplayName "OpenSUSE ISO"
```

**Alternative: Download via browser:**
- Visit: https://get.opensuse.org/leap/16.0/
- Click "Offline Image" 
- Save to: `Z:\ISOs\Leap-16.0-offline-installer-x86_64.install.iso`

**3. Verify ISO checksum (optional but recommended):**
```powershell
# Get the SHA256 hash of your downloaded file
Get-FileHash "Z:\ISOs\Leap-16.0-offline-installer-x86_64.install.iso" -Algorithm SHA256
```

Compare the output with the checksum from the [OpenSUSE download page](https://get.opensuse.org/leap/16.0/).

## Network Configuration

Hyper-V will create a virtual switch for your VM. The setup script will use:
- **Default Switch** (easiest) - provides NAT and internet access automatically
- Or you can specify an external switch if you want the VM on your local network

## Storage Location

The VM will be created in the default Hyper-V location, typically:
```
C:\ProgramData\Microsoft\Windows\Hyper-V\
```

Or a custom location if you've configured one. The setup script will respect your Hyper-V defaults.

## Checklist

Before proceeding to VM setup:

- [ ] Windows Pro/Enterprise/Education edition confirmed
- [ ] Virtualization enabled in BIOS/UEFI
- [ ] Hyper-V feature enabled
- [ ] Computer restarted after enabling Hyper-V
- [ ] SUSE/OpenSUSE downloaded (ISO or pre-built VM)
- [ ] ISO checksum verified (optional, if using ISO)
- [ ] At least 10 GB free disk space (40 GB+ recommended)
- [ ] Running PowerShell as Administrator (required for Hyper-V operations)

## Create the VM

Now that you have the ISO downloaded, create the VM with the creation script:

```powershell
.\scripts\setup\01-create-vm.ps1 -IsoPath "Z:\ISOs\Leap-16.0-offline-installer-x86_64.install.iso"
```

**What the script does:**
- Creates a new Hyper-V VM named "OpenSUSE-Leap-16"
- Creates a 40 GB virtual hard disk (expands dynamically)
- Configures 2 CPU cores and 2 GB RAM (adjustable)
- Attaches the ISO to DVD drive
- Configures network adapter (Default Switch)
- Sets up Generation 2 VM (UEFI boot)
- Optionally starts the VM and opens console

**Script parameters (optional):**
```powershell
# Customize VM resources
.\scripts\setup\01-create-vm.ps1 `
    -IsoPath "Z:\ISOs\Leap-16.0-offline-installer-x86_64.install.iso" `
    -VMName "MySUSEServer" `
    -Memory 4GB `
    -CPUCount 4 `
    -DiskSize 80GB
```

## Manual Installation Steps

> **📚 Installation Reference:**
> - [OpenSUSE Installation Quick Start](https://doc.opensuse.org/documentation/leap/startup/html/book-startup/art-opensuse-installquick.html)
> - [Detailed Installation Guide](https://doc.opensuse.org/documentation/leap/startup/html/book-startup/cha-install.html)

After the script completes and the VM console opens, follow these steps to install OpenSUSE:

### Step 1: Boot from ISO

The VM should automatically boot from the ISO. You'll see the OpenSUSE boot menu.

**Select:** `Installation` (usually the first option)

Press **Enter** to begin.

### Step 2: Language and Keyboard

**Language Selection:**
- Select your preferred language (English is typical)
- Click **Next**

**Keyboard Layout:**
- Select your keyboard layout
- Test in the text field to verify
- Click **Next**

### Step 3: Network Configuration

The installer will attempt to configure network automatically via DHCP (from Hyper-V Default Switch).

- Verify network is configured (should show IP address)
- Click **Next** to continue

If network configuration fails:
- You can configure it later after installation
- Click **Next** to skip for now

### Step 4: System Role

**Select:** `Server` or `Server (Text Mode)`

**Recommendation:** Choose `Server (Text Mode)` for minimal installation focused on learning.

Click **Next**

### Step 5: Disk Partitioning

**Guided Setup (Recommended for beginners):**
- Select **Guided Setup**
- Choose **Use Entire Hard Disk**
- Accept default partition scheme
- Click **Next**

**Note:** The default scheme typically creates:
- Root partition (`/`)
- Swap space
- UEFI boot partition

### Step 6: Time Zone

- Select your time zone
- Verify hardware clock setting (usually UTC)
- Click **Next**

### Step 7: Create Local User

**Important:** Create your regular user account here.

**Fill in:**
- **Username:** (your preferred username)
- **Full Name:** (your name)
- **Password:** (strong password)
- **Confirm Password:**

**Options:**
- ☑ **Use this password for system administrator** (recommended for learning setup)
- ☑ **Automatic Login** (optional, not recommended for SSH-accessible systems)

Click **Next**

**Security Note:** This sets the same password for both your user and root. You can change root password separately later if desired.

### Step 8: Installation Settings Summary

Review the installation summary:
- Partitioning scheme
- Software selection
- Bootloader settings
- Network configuration

**Software Selection:**
- For minimal server: Should include base system, SSH server
- Click **Software** if you want to add/remove packages

**To proceed:**
Click **Install**

### Step 9: Confirm Installation

A final confirmation dialog will appear warning that data will be written to disk.

Click **Install** to confirm and begin installation.

### Step 10: Installation Progress

The installation will now proceed:
- Formatting partitions
- Installing packages
- Configuring bootloader
- Setting up system

**Duration:** Typically 5-15 minutes depending on hardware.

### Step 11: Installation Complete

When installation completes:

1. Click **Finish**
2. VM will reboot automatically
3. Remove ISO (or leave it, Hyper-V will prioritize disk boot after first boot)

The system will boot into OpenSUSE.

## First Login and Initial Configuration

> **📚 Post-Installation Reference:**
> - [OpenSUSE System Configuration](https://doc.opensuse.org/documentation/leap/startup/html/book-startup/cha-yast-software.html)
> - [Network Configuration Guide](https://doc.opensuse.org/documentation/leap/reference/html/book-reference/cha-network.html)

After the VM reboots, you'll reach the login prompt.

### Step 1: Login

```
Login: <your-username>
Password: <your-password>
```

Or login as root if you need administrative access immediately:
```
Login: root
Password: <same-password>
```

### Step 2: Verify Network

Check that network is working:

```bash
ip addr show
ping -c 3 google.com
```

If network isn't configured:
```bash
# Check network interfaces
ip link show

# Configure network (as root)
sudo yast lan
# Follow the YaST network configuration interface
```

### Step 3: Update System Packages

Update the system to latest packages:

```bash
sudo zypper refresh
sudo zypper update -y
```

### Step 4: Install Essential Tools

Install any additional tools you'll need:

```bash
sudo zypper install -y vim openssh
```

### Step 5: Enable SSH

Enable and start SSH service for remote access:

```bash
sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl status sshd
```

Verify SSH is listening:
```bash
sudo ss -tulpn | grep :22
```

### Step 6: Configure Firewall (if needed)

Check firewall status:
```bash
sudo systemctl status firewalld
```

If firewall is active and blocking SSH:
```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

### Step 7: Get VM IP Address

Find your VM's IP address for SSH access:

```bash
ip addr show eth0
```

Or from Windows PowerShell:
```powershell
Get-VMNetworkAdapter -VMName "OpenSUSE-Leap-16" | Select IPAddresses
```

### Step 8: Verify User Configuration

If you didn't create a regular user during installation, create one now:

```bash
# As root
useradd -m -G wheel <username>
passwd <username>

# Allow wheel group to use sudo
echo "%wheel ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/wheel
```

## VM Management Commands

**Useful Hyper-V commands from Windows:**

```powershell
# Start/Stop VM
Start-VM "OpenSUSE-Leap-16"
Stop-VM "OpenSUSE-Leap-16"

# Check VM status
Get-VM "OpenSUSE-Leap-16"

# Create checkpoint (snapshot)
Checkpoint-VM "OpenSUSE-Leap-16" -SnapshotName "Fresh-Install"

# Restore checkpoint
Restore-VMSnapshot -Name "Fresh-Install" -VMName "OpenSUSE-Leap-16" -Confirm:$false

# Get VM IP address
Get-VMNetworkAdapter -VMName "OpenSUSE-Leap-16" | Select IPAddresses
```

## Troubleshooting

**Boot issues:**
- Ensure VM is set to boot from DVD first (for installation)
- After installation, VM should boot from disk automatically
- Check boot order: `Get-VMFirmware -VMName "OpenSUSE-Leap-16"`

**Network not working:**
- Verify Default Switch exists: `Get-VMSwitch`
- Check VM network adapter: `Get-VMNetworkAdapter -VMName "OpenSUSE-Leap-16"`
- Inside VM: `sudo yast lan` to configure network manually

**Can't login:**
- Verify username and password entered during installation
- Try root user with same password
- If forgotten, boot into recovery mode to reset password

**Installation hangs:**
- Check VM has enough resources (CPU, RAM)
- Verify ISO is not corrupted (check SHA256 hash)
- Try restarting VM and installation

## Next Steps

Now that your VM is functional with SSH enabled, proceed to:

**[SSH Access](03-ssh-access.md)** - Configure SSH keys and connect from Windows or VS Code
