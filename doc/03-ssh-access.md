# SSH Access to Your VM

> **📚 Official Documentation:**
> - [OpenSSH Documentation](https://www.openssh.com/manual.html)
> - [OpenSUSE Security Guide - SSH](https://doc.opensuse.org/documentation/leap/security/html/book-security/cha-ssh.html)
> - [Microsoft: SSH Authentication Methods](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement)
> - [Microsoft: OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview)

Now that your VM is running with SSH enabled, you need to establish secure access from your Windows host machine.

## Access Methods Available

There are several ways to access your VM:

| Method | Interface Type | Best For | Requires Network |
|--------|----------------|----------|------------------|
| **Hyper-V Console** | Text terminal (direct) | Initial setup, troubleshooting | No |
| **SSH Client** | Text terminal (network) | Day-to-day administration | Yes |
| **VS Code Remote-SSH** | GUI file editor + terminal | Development, file editing | Yes |

### About Graphical Desktop (GUI)

**Current setup:** Your VM is running a **minimal server** installation (text-only, no graphical desktop).

**Why?** Server systems typically run without a GUI because:
- More secure (smaller attack surface)
- Uses less resources (RAM, CPU)
- Faster and more efficient
- Standard practice for Linux servers

**Can you add a GUI?** Yes! You can install desktop environments like:
- **GNOME** - Full-featured desktop (like Windows/Mac)
- **KDE Plasma** - Customizable desktop
- **XFCE** - Lightweight desktop

**Should you?** For learning server administration: **Not recommended**
- Adds 2-4 GB of packages
- Uses significant RAM/CPU
- Not representative of real server environments
- SSH and terminal skills are what you need for work

**Hyper-V Console access:** The Hyper-V console connection IS direct screen access to your VM - it just shows a text terminal instead of a graphical desktop. This is normal and expected for servers.

## Connection Methods Overview

This document covers SSH access methods (network-based):

| Method | Best For | Covered In |
|--------|----------|------------|
| **Standard SSH Client** | General server administration, terminal access | This section (recommended) |
| **VS Code Remote-SSH** | File editing, integrated development workflow | Optional section below |

**This guide recommends starting with a standard SSH client** to understand the fundamentals. VS Code Remote-SSH is an excellent tool but builds on these basics.

## Prerequisites

Before connecting, ensure:
- [ ] VM is running and SSH service is enabled
- [ ] You know your VM's IP address
- [ ] You have your username and password

**Get VM IP address:**

From Windows PowerShell:
```powershell
Get-VMNetworkAdapter -VMName "OpenSUSE-Leap-16" | Select-Object IPAddresses
```

Or from within the VM console:
```bash
ip addr show eth0 | grep "inet "
```

## Method 1: Standard SSH Client (Recommended)

Modern Windows (10/11) includes OpenSSH client by default.

### Step 1: Verify SSH Client is Available

Open PowerShell and check:

```powershell
ssh -V
```

You should see output like: `OpenSSH_for_Windows_8.x.x`

If not found, install OpenSSH client:
```powershell
# Run as Administrator
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

### Step 2: Generate SSH Key Pair (Recommended)

**Why use SSH keys?**
- More secure than passwords
- No password prompts once configured
- Required for automated scripts

**Generate keys:**

```powershell
# Create .ssh directory if it doesn't exist
New-Item -Path "$env:USERPROFILE\.ssh" -ItemType Directory -Force

# Generate ED25519 key pair (modern, secure)
ssh-keygen -t ed25519 -C "your.email@example.com" -f "$env:USERPROFILE\.ssh\id_ed25519"
```

**During key generation:**
- Press Enter to accept default location
- Enter a passphrase (recommended) or leave empty for no passphrase
- Re-enter passphrase to confirm

**Result:** Two files created:
- `~\.ssh\id_ed25519` - Private key (keep secret!)
- `~\.ssh\id_ed25519.pub` - Public key (safe to share)

### Step 3: Copy Public Key to VM

**Option A: Using ssh-copy-id (if available):**

```powershell
# Copy public key to VM (replace with your VM's IP and username)
ssh-copy-id -i "$env:USERPROFILE\.ssh\id_ed25519.pub" yourusername@<VM_IP_ADDRESS>
```

**Option B: Manual copy (always works):**

1. Display your public key:
```powershell
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"
```

2. Copy the entire output (starts with `ssh-ed25519 ...`)

3. Connect to VM with password:
```powershell
ssh yourusername@<VM_IP_ADDRESS>
```

4. On the VM, add the public key:
```bash
# Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add public key to authorized_keys
echo "ssh-ed25519 AAAA...your-public-key-here...== your.email@example.com" >> ~/.ssh/authorized_keys

# Set correct permissions
chmod 600 ~/.ssh/authorized_keys
```

5. Exit the VM:
```bash
exit
```

### Step 4: Connect Using SSH Keys

Now connect without password:

```powershell
ssh yourusername@<VM_IP_ADDRESS>
```

If you set a passphrase, you'll be prompted for it (one-time per session).

**Success!** You should now be logged into your VM.

### Step 5: Create SSH Config (Optional but Recommended)

Make connecting easier with an SSH config file:

```powershell
# Create/edit SSH config
notepad "$env:USERPROFILE\.ssh\config"
```

Add this content (adjust values):

```
Host suse-server
    HostName <VM_IP_ADDRESS>
    User yourusername
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Save and close.

**Now connect simply with:**
```powershell
ssh suse-server
```

## Alternative: Password-Based Authentication

> **⚠️ Note:** Password-based authentication is less secure and not recommended for production systems. However, it's simpler for initial testing or local lab environments.
>
> **For more details:** See [Microsoft's SSH Authentication Guide](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement)

**To connect with password only:**

```powershell
ssh yourusername@<VM_IP_ADDRESS>
```

Enter your password when prompted.

**Limitations:**
- Must enter password for every connection
- More vulnerable to brute-force attacks
- Not suitable for automation

---
---

## Method 2: VS Code Remote-SSH (Optional)

> **Best for:** Developers who want to edit files on the VM directly in VS Code with full IDE features.

### Prerequisites

- [ ] SSH key-based authentication configured (see above)
- [ ] VS Code installed on Windows
- [ ] You can successfully connect via standard SSH client

### Step 1: Install Remote-SSH Extension

1. Open VS Code
2. Click Extensions icon (or press `Ctrl+Shift+X`)
3. Search for **"Remote - SSH"**
4. Install the extension by Microsoft

### Step 2: Configure Remote-SSH

**Option A: Using SSH config file (recommended if you created one):**

1. In VS Code, press `F1` or `Ctrl+Shift+P`
2. Type: `Remote-SSH: Connect to Host`
3. Select your configured host: `suse-server`
4. Select platform: **Linux**
5. VS Code will connect and install VS Code Server on the VM

**Option B: Direct connection:**

1. Press `F1` or `Ctrl+Shift+P`
2. Type: `Remote-SSH: Connect to Host`
3. Select **Add New SSH Host**
4. Enter: `ssh yourusername@<VM_IP_ADDRESS>`
5. Select SSH config file to update: `C:\Users\<YourUser>\.ssh\config`
6. Connect to the new host

### Step 3: Open Folder on Remote

Once connected:

1. Click **Open Folder** in VS Code welcome screen
2. Navigate to your home directory: `/home/yourusername`
3. Click **OK**

You're now working directly on the VM filesystem!

### Step 4: Install Useful Extensions (Optional)

With Remote-SSH connected, install extensions on the remote:

**Recommended for Linux administration:**
- **YAML** (Red Hat) - For configuration files
- **ShellCheck** - Bash script linting
- **Remote - SSH: Editing Configuration Files** - Easy SSH config editing

**Recommended for PostgreSQL (future):**
- **PostgreSQL** (Chris Kolkman) - SQL syntax highlighting
- **SQLTools** - Database management

Extensions are installed separately for remote and local contexts.

## Testing Your Connection

### Basic Connection Test

```powershell
# From PowerShell
ssh yourusername@<VM_IP_ADDRESS> 'echo "SSH is working!"'
```

Should output: `SSH is working!`

### Check SSH Service on VM

Connect to VM and verify:

```bash
sudo systemctl status sshd
sudo ss -tulpn | grep :22
```

Both should show SSH running and listening on port 22.

## Troubleshooting

### Cannot connect - Connection refused

**Check SSH service on VM:**
```bash
# From VM console
sudo systemctl status sshd
sudo systemctl start sshd
```

**Check firewall:**
```bash
sudo firewall-cmd --list-all | grep ssh
```

If SSH not allowed:
```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

### Connection timeout

**Check VM IP address hasn't changed:**
```powershell
Get-VMNetworkAdapter -VMName "OpenSUSE-Leap-16" | Select IPAddresses
```

**Check VM is running:**
```powershell
Get-VM "OpenSUSE-Leap-16"
```

### Permission denied (publickey)

**Check public key is correctly installed on VM:**
```bash
cat ~/.ssh/authorized_keys
```

**Verify permissions:**
```bash
ls -la ~/.ssh/
# authorized_keys should be -rw------- (600)
# .ssh directory should be drwx------ (700)
```

**Fix permissions if needed:**
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### "Host key verification failed"

This happens when VM IP changed or was reinstalled.

**Remove old host key:**
```powershell
ssh-keygen -R <VM_IP_ADDRESS>
```

Then reconnect (you'll be asked to verify new host key).

### VS Code can't connect

**Ensure standard SSH works first:**
```powershell
ssh yourusername@<VM_IP_ADDRESS>
```

**Check VS Code Remote-SSH logs:**
1. In VS Code: `View` → `Output`
2. Select `Remote - SSH` from dropdown
3. Review error messages

**Common fix - Reset VS Code Server:**
```bash
# On the VM
rm -rf ~/.vscode-server
```

Then reconnect from VS Code.

## Security Best Practices

> **Important:** After establishing SSH access, proceed immediately to [SSH Security Hardening](04-ssh-hardening.md) to secure your server properly.

Basic security recommendations:
- ✅ Use SSH keys instead of passwords
- ✅ Use strong passphrases for private keys
- ✅ Keep private keys secure (never share `id_ed25519`)
- ⚠️ Don't disable firewall
- ⚠️ Don't allow root SSH login (we'll configure this in next step)

## Next Steps

Now that you have SSH access configured:

1. **[SSH Security Hardening](04-ssh-hardening.md)** ⚠️ **Do this next!** - Secure your SSH configuration
2. **[General System Configuration](05-system-config.md)** - Configure system settings and learn basic commands
