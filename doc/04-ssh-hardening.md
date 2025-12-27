# SSH Security Hardening

> **📚 Official Documentation:**
> - [OpenSUSE Security Guide - SSH Hardening](https://doc.opensuse.org/documentation/leap/security/html/book-security/cha-ssh.html#sec-ssh-authentic)
> - [SSH Security Best Practices (NIST)](https://nvlpubs.nist.gov/nistpubs/ir/2015/NIST.IR.7966.pdf)
> - [CIS Benchmark for SUSE Linux](https://www.cisecurity.org/benchmark/suse_linux)

After establishing SSH access, it's critical to harden your SSH configuration to prevent unauthorized access and attacks.

## Why Harden SSH?

SSH is often the primary attack vector for servers. Common threats include:
- Brute-force password attacks
- Compromised credentials
- Automated bot scanning for SSH on default port
- Privilege escalation via root login

**This guide implements industry-standard SSH hardening practices.**

## Prerequisites

Before proceeding:
- [ ] You have SSH access working (completed [SSH Access](03-ssh-access.md))
- [ ] You have key-based authentication configured and tested
- [ ] You have sudo privileges on the VM
- [ ] You're connected via standard SSH or VS Code Remote-SSH

## ⚠️ Create VM Checkpoint (Snapshot)

**Important:** Before hardening SSH, create a Hyper-V checkpoint so you can rollback if something goes wrong.

From Windows PowerShell:
```powershell
Checkpoint-VM -Name "OpenSUSE-Leap-16" -SnapshotName "Before-SSH-Hardening"
```

This allows you to restore if you accidentally lock yourself out.

## Backup Current Configuration

Always back up before making changes:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d)
```

## Step 1: Disable Root Login

**Why:** Root login via SSH is a major security risk. Attackers know the username (root) and only need to guess the password.

**Edit SSH config:**
```bash
sudo vim /etc/ssh/sshd_config
```

Or using sed:
```bash
sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
```

**Verify the change:**
```bash
grep "^PermitRootLogin" /etc/ssh/sshd_config
```

Should show: `PermitRootLogin no`

## Step 2: Disable Password Authentication

**Why:** Forces use of SSH keys, which are far more secure than passwords.

**⚠️ CRITICAL WARNING:** Once you disable password authentication:
- **Only SSH keys will work** - password login will be permanently blocked
- **If you lose your private key (`~/.ssh/id_ed25519`)** you will be locked out
- **Keep your private key backed up securely** (never commit to git, never share)
- You can still access VM via Hyper-V console if needed

**Before proceeding, verify:**
1. ✅ Key-based auth is working (test below)
2. ✅ You know where your private key is stored (`%USERPROFILE%\.ssh\id_ed25519`)
3. ✅ Your private key is backed up to a secure location

**Test key-based auth first:**
```powershell
# From Windows - this should work WITHOUT asking for password
ssh yourusername@<VM_IP_ADDRESS> 'echo "Key auth works!"'
```

**Only proceed if the above works without password prompt.**

**Disable password authentication:**
```bash
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
```

**Also disable challenge-response authentication:**
```bash
sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
```

**Verify changes:**
```bash
grep "^PasswordAuthentication" /etc/ssh/sshd_config
grep "^ChallengeResponseAuthentication" /etc/ssh/sshd_config
```

## Step 3: Restrict User Access (Optional)

**Why:** Limit which users can SSH into the system.

**Allow only specific users:**
```bash
# Add only if not already present
grep -q "^AllowUsers" /etc/ssh/sshd_config || echo "AllowUsers yourusername" | sudo tee -a /etc/ssh/sshd_config
```

**Or allow specific groups:**
```bash
# Add only if not already present
grep -q "^AllowGroups" /etc/ssh/sshd_config || echo "AllowGroups wheel ssh-users" | sudo tee -a /etc/ssh/sshd_config
```

## Step 4: Configure SSH Protocol and Ciphers

**Use only SSH Protocol 2:**
```bash
# Add only if not already present
grep -q "^Protocol 2" /etc/ssh/sshd_config || echo "Protocol 2" | sudo tee -a /etc/ssh/sshd_config
```

**Use strong ciphers only:**
```bash
sudo tee -a /etc/ssh/sshd_config > /dev/null <<'EOF'

# Strong ciphers only
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
EOF
```

## Step 5: Set Connection Limits and Timeouts

**Reduce login grace time:**
```bash
# Uncomment if commented, otherwise add
sudo sed -i 's/^#LoginGraceTime.*/LoginGraceTime 30/' /etc/ssh/sshd_config
grep -q "^LoginGraceTime" /etc/ssh/sshd_config || echo "LoginGraceTime 30" | sudo tee -a /etc/ssh/sshd_config
```

**Set maximum authentication attempts:**
```bash
grep -q "^MaxAuthTries" /etc/ssh/sshd_config || echo "MaxAuthTries 3" | sudo tee -a /etc/ssh/sshd_config
```

**Set maximum sessions:**
```bash
grep -q "^MaxSessions" /etc/ssh/sshd_config || echo "MaxSessions 2" | sudo tee -a /etc/ssh/sshd_config
```

**Client timeout (disconnects inactive sessions):**
```bash
grep -q "^ClientAliveInterval" /etc/ssh/sshd_config || echo "ClientAliveInterval 300" | sudo tee -a /etc/ssh/sshd_config
grep -q "^ClientAliveCountMax" /etc/ssh/sshd_config || echo "ClientAliveCountMax 2" | sudo tee -a /etc/ssh/sshd_config
```

## Step 6: Disable Empty Passwords

**Ensure no accounts with empty passwords can login:**
```bash
sudo sed -i 's/^#PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
grep -q "^PermitEmptyPasswords" /etc/ssh/sshd_config || echo "PermitEmptyPasswords no" | sudo tee -a /etc/ssh/sshd_config
```

## Step 7: Disable X11 Forwarding (If Not Needed)

**Why:** X11 forwarding can be exploited if not needed.

```bash
sudo sed -i 's/^X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
```

## Step 8: Configure Logging

**Ensure SSH logs are verbose:**
```bash
sudo sed -i 's/^#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config
grep -q "^LogLevel" /etc/ssh/sshd_config || echo "LogLevel VERBOSE" | sudo tee -a /etc/ssh/sshd_config
```

## Step 9: Review Final Configuration

**Check for syntax errors:**
```bash
sudo sshd -t
```

Should show: `(nothing)` or `sshd: no errors`

**View key security settings:**
```bash
grep -E "^(PermitRootLogin|PasswordAuthentication|ChallengeResponseAuthentication|PubkeyAuthentication)" /etc/ssh/sshd_config
```

Expected output:
```
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
PermitRootLogin no
```

## Step 10: Apply Changes

**⚠️ IMPORTANT:** Do NOT close your current SSH session until you've tested a new connection!

**Restart SSH service:**
```bash
sudo systemctl restart sshd
```

**Verify SSH is still running:**
```bash
sudo systemctl status sshd
```

## Step 11: Test New Connection

**Open a NEW terminal/PowerShell window** (keep your current SSH session open!)

**Test connection:**
```powershell
ssh yourusername@<VM_IP_ADDRESS>
```

**Verify:**
- ✅ Connection succeeds with SSH key
- ✅ No password prompt
- ✅ You can sudo successfully

**If successful:** Your configuration is working! You can close the old session.

**If unsuccessful:** Use your old session to revert:
```bash
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## Optional: Change SSH Port

**Why:** Moving SSH off port 22 reduces automated attack attempts.

**⚠️ Note:** This is "security through obscurity" - useful but not a replacement for proper hardening.

**Change port:**
```bash
# Choose a high port number (e.g., 2222, 2200, etc.)
sudo sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
```

**Update firewall:**
```bash
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --reload
```

**Restart SSH:**
```bash
sudo systemctl restart sshd
```

**Connect using new port:**
```powershell
ssh -p 2222 yourusername@<VM_IP_ADDRESS>
```

**Update SSH config file:**
```powershell
notepad "$env:USERPROFILE\.ssh\config"
```

Add:
```
Host suse-server
    HostName <VM_IP_ADDRESS>
    User yourusername
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
```

## Optional: Install and Configure Fail2ban

**Why:** Automatically bans IPs after failed login attempts.

**Install fail2ban:**
```bash
sudo zypper install -y fail2ban
```

**Enable and start:**
```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

**Create local configuration:**
```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

**Edit configuration:**
```bash
sudo vim /etc/fail2ban/jail.local
```

Find `[sshd]` section and ensure:
```
[sshd]
enabled = true
port = ssh
logpath = /var/log/messages
maxretry = 3
bantime = 3600
findtime = 600
```

**Restart fail2ban:**
```bash
sudo systemctl restart fail2ban
```

**Check status:**
```bash
sudo fail2ban-client status sshd
```

## Verify Security Posture

**Check who can login:**
```bash
sudo grep "^AllowUsers" /etc/ssh/sshd_config
```

**Check recent authentication attempts:**
```bash
sudo journalctl -u sshd | tail -n 50
```

**Check for failed login attempts:**
```bash
sudo grep "Failed password" /var/log/messages | tail -n 20
```

## Security Checklist

After completing this guide, verify:

- [ ] Root login via SSH is disabled
- [ ] Password authentication is disabled
- [ ] Key-based authentication is working
- [ ] You can still connect via SSH
- [ ] You can still use sudo
- [ ] SSH is logging verbosely
- [ ] Strong ciphers are enforced
- [ ] Connection timeouts are configured
- [ ] You've tested a new connection successfully

## Monitoring and Maintenance

**Regular checks:**

```bash
# View recent SSH connections
sudo journalctl -u sshd --since "1 hour ago"

# Check fail2ban bans (if installed)
sudo fail2ban-client status sshd

# Review authentication logs
sudo grep -i "sshd" /var/log/messages | tail -n 50
```

**Monthly:** Review and update SSH configuration as needed.

## Troubleshooting

### Locked out after hardening

**Solution:** Connect via Hyper-V console:

```powershell
# From Windows
vmconnect localhost "OpenSUSE-Leap-16"
```

Login at console and revert changes:
```bash
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### Permission denied after disabling passwords

**Check:** Key-based authentication is properly configured:
```bash
ls -la ~/.ssh/authorized_keys
# Should be -rw------- (600)

cat ~/.ssh/authorized_keys
# Should contain your public key
```

### SSH won't start after configuration change

**Check syntax:**
```bash
sudo sshd -t
```

**View errors:**
```bash
sudo journalctl -u sshd -n 50
```

**Revert to backup:**
```bash
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## Additional Resources

- [OpenSSH Best Practices](https://www.ssh.com/academy/ssh/config)
- [Mozilla SSH Guidelines](https://infosec.mozilla.org/guidelines/openssh)
- [SSH Audit Tool](https://github.com/jtesta/ssh-audit) - Scan your SSH configuration

## Next Steps

Your SSH access is now hardened and secure. Proceed to:

**[General System Configuration](05-system-config.md)** - Configure system settings and learn basic commands
