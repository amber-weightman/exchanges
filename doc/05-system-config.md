# General System Configuration

> **📚 Official Documentation:**
> - [OpenSUSE Administration Guide](https://doc.opensuse.org/documentation/leap/archive/16.0/reference/html/book-reference/index.html)
> - [OpenSUSE System Configuration (YaST)](https://doc.opensuse.org/documentation/leap/startup/html/book-startup/cha-yast-gui.html)
> - [OpenSUSE Command Line Basics](https://doc.opensuse.org/documentation/leap/reference/html/book-reference/cha-util.html)

Now that your VM is set up with secure SSH access, configure basic system settings and learn essential commands for operating your SUSE server.

## System Information

### Check System Details

```bash
# OS version
cat /etc/os-release

# Kernel version
uname -r

# System uptime
uptime

# CPU information
lscpu

# Memory information
free -h

# Disk usage
df -h
```

## Step 1: Configure Timezone

**Check current timezone:**
```bash
timedatectl
```

**List available timezones:**
```bash
timedatectl list-timezones | grep -i sydney    # For Sydney
timedatectl list-timezones | grep -i melbourne # For Melbourne
timedatectl list-timezones | grep -i brisbane  # For Brisbane
```

**Set timezone:**
```bash
# Example for Sydney
sudo timedatectl set-timezone Australia/Sydney

# Verify
timedatectl
```

## Step 2: Configure Locale

**Check current locale:**
```bash
localectl
```

**List available locales:**
```bash
localectl list-locales | grep en_AU    # Australian English
localectl list-locales | grep en_US    # US English
```

**Set locale:**
```bash
# Example for Australian English
sudo localectl set-locale LANG=en_AU.UTF-8

# Verify
localectl
```

**Note:** Logout and login again for locale changes to take full effect.

## Step 3: Set Hostname

**Check current hostname:**
```bash
hostnamectl
```

**Set a meaningful hostname:**
```bash
# Use lowercase, hyphens instead of spaces
sudo hostnamectl set-hostname suse-server

# Or be more specific
sudo hostnamectl set-hostname suse-dev-vm

# Verify
hostnamectl
```

## Step 4: Update System

**Refresh repositories:**
```bash
sudo zypper refresh
```

**Update all packages:**
```bash
sudo zypper update -y
```

**Check for required reboots:**
```bash
sudo zypper ps -s
```

If reboot is needed:
```bash
sudo reboot
```

## Step 5: Install Essential Tools

**Useful system utilities:**
```bash
sudo zypper install -y \
    vim \
    htop \
    tmux \
    tree \
    curl \
    wget \
    git \
    net-tools \
    bind-utils \
    lsof \
    rsync
```

**Package descriptions:**
- `vim` - Advanced text editor
- `htop` - Interactive process viewer
- `tmux` - Terminal multiplexer (multiple sessions)
- `tree` - Directory tree viewer
- `curl/wget` - Download tools
- `git` - Version control
- `net-tools` - Network utilities (ifconfig, netstat)
- `bind-utils` - DNS tools (nslookup, dig)
- `lsof` - List open files
- `rsync` - File synchronization tool

## Step 6: Configure Automatic Updates (Optional)

**Check if automatic updates are enabled:**
```bash
systemctl status zypp-refresh.service
```

**Enable automatic repository refresh:**
```bash
sudo systemctl enable zypp-refresh.timer
sudo systemctl start zypp-refresh.timer
```

**Configure automatic security updates:**
```bash
# Install automatic update tools
sudo zypper install -y yast2-online-update-configuration

# Configure via YaST
sudo yast2 online_update_configuration
```

In YaST interface:
- Enable **Automatic Online Update**
- Select **Security Updates Only** (recommended for learning environment)
- Set schedule (daily recommended)

## Step 7: Configure Firewall

**Check firewall status:**
```bash
sudo firewall-cmd --state
sudo firewall-cmd --list-all
```

**Common firewall commands:**
```bash
# List enabled services
sudo firewall-cmd --list-services

# Add a service permanently
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Add a specific port
sudo firewall-cmd --permanent --add-port=5432/tcp  # PostgreSQL (for later)

# Reload firewall
sudo firewall-cmd --reload

# Remove a service
sudo firewall-cmd --permanent --remove-service=dhcpv6-client
sudo firewall-cmd --reload
```

**Current recommended services for this setup:**
```bash
# Keep SSH only for now
sudo firewall-cmd --list-services
# Should show: ssh
```

## Step 8: Configure System Logging

**View system logs:**
```bash
# Recent system messages
sudo journalctl -n 50

# Follow logs in real-time
sudo journalctl -f

# Logs for specific service
sudo journalctl -u sshd

# Logs since specific time
sudo journalctl --since "1 hour ago"
sudo journalctl --since "2024-12-27 10:00:00"

# Boot messages
sudo journalctl -b
```

**Check disk usage by logs:**
```bash
sudo journalctl --disk-usage
```

**Configure log retention (optional):**
```bash
sudo vim /etc/systemd/journald.conf
```

Set:
```
SystemMaxUse=500M
MaxRetentionSec=1month
```

Restart journald:
```bash
sudo systemctl restart systemd-journald
```

## Step 9: User and Group Management

**List all users:**
```bash
cat /etc/passwd | grep -v nologin | grep -v false
```

**List groups:**
```bash
groups yourusername
```

**Add user to group:**
```bash
sudo usermod -aG wheel yourusername  # wheel = sudo access
```

**Create new user (if needed):**
```bash
sudo useradd -m -G wheel -s /bin/bash newuser
sudo passwd newuser
```

## Step 10: Disk and File System Management

**Check disk usage:**
```bash
df -h
lsblk
```

**Check largest directories:**
```bash
sudo du -h --max-depth=1 / | sort -rh | head -10
```

**Check inode usage:**
```bash
df -i
```

**Clean package cache (if needed):**
```bash
sudo zypper clean --all
```

## Essential Commands Reference

### Package Management (zypper)

```bash
# Search for package
zypper search package-name

# Get package info
zypper info package-name

# Install package
sudo zypper install package-name

# Remove package
sudo zypper remove package-name

# Update specific package
sudo zypper update package-name

# List installed packages
zypper search --installed-only

# List repositories
zypper repos

# Clean cache
sudo zypper clean --all
```

### Service Management (systemd)

```bash
# Check service status
sudo systemctl status service-name

# Start service
sudo systemctl start service-name

# Stop service
sudo systemctl stop service-name

# Restart service
sudo systemctl restart service-name

# Enable service (start at boot)
sudo systemctl enable service-name

# Disable service
sudo systemctl disable service-name

# List all services
systemctl list-units --type=service

# List enabled services
systemctl list-unit-files --type=service --state=enabled
```

### File Operations

```bash
# Find files
find /path -name "filename"
find /home -type f -name "*.log"

# Search file contents
grep -r "search-term" /path

# File permissions
chmod 644 file.txt           # rw-r--r--
chmod 755 script.sh          # rwxr-xr-x
chmod 700 private-dir/       # rwx------

# Change ownership
sudo chown user:group file.txt
sudo chown -R user:group directory/
```

### Network Commands

```bash
# Check network interfaces
ip addr show
ip link show

# Check routing
ip route show

# Check listening ports
sudo ss -tulpn
sudo netstat -tulpn

# Check connectivity
ping -c 4 google.com

# DNS lookup
nslookup google.com
dig google.com

# Download file
wget https://example.com/file.tar.gz
curl -O https://example.com/file.tar.gz
```

### Process Management

```bash
# List processes
ps aux
ps aux | grep process-name

# Interactive process viewer
htop

# Kill process
kill PID
kill -9 PID  # Force kill

# Kill by name
pkill process-name
```

## Performance Monitoring

**CPU usage:**
```bash
top
htop
mpstat 1  # requires sysstat package
```

**Memory usage:**
```bash
free -h
vmstat 1
```

**Disk I/O:**
```bash
iostat -x 1  # requires sysstat package
```

**Network:**
```bash
# Install if needed
sudo zypper install -y iftop nethogs

# Monitor bandwidth
sudo iftop

# Per-process network usage
sudo nethogs
```

## System Backup Considerations

**Important directories to back up:**
- `/home` - User files
- `/etc` - Configuration files
- `/root` - Root user files
- `/var/www` - Web files (if applicable)
- Database dumps (when you set up PostgreSQL)

**Simple backup script example:**
```bash
#!/bin/bash
# Save as /usr/local/bin/backup-configs.sh

BACKUP_DIR="/home/yourusername/backups"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

# Backup /etc
sudo tar -czf $BACKUP_DIR/etc-$DATE.tar.gz /etc

# Backup home directory
tar -czf $BACKUP_DIR/home-$DATE.tar.gz /home/yourusername

echo "Backup completed: $DATE"
```

**For now:** Use Hyper-V checkpoints/snapshots as your primary backup method.

## System Maintenance Tasks

**Weekly:**
- Check system updates: `sudo zypper update`
- Review logs: `sudo journalctl -p err -n 50`
- Check disk space: `df -h`

**Monthly:**
- Clean package cache: `sudo zypper clean --all`
- Review installed packages: `zypper search --installed-only`
- Create Hyper-V checkpoint (snapshot)

## Troubleshooting Quick Reference

**System won't boot:**
- Connect via Hyper-V console
- Check systemd failed services: `systemctl --failed`
- Review boot logs: `sudo journalctl -b`

**High CPU usage:**
- Check processes: `htop` or `top`
- Identify process: `ps aux | sort -nrk 3 | head`

**High memory usage:**
- Check memory: `free -h`
- List memory by process: `ps aux | sort -nrk 4 | head`

**Disk full:**
- Find large directories: `sudo du -h --max-depth=1 / | sort -rh | head`
- Clean logs: `sudo journalctl --vacuum-size=100M`
- Clean cache: `sudo zypper clean --all`

**Network issues:**
- Check interface: `ip link show`
- Check IP: `ip addr show`
- Check routing: `ip route show`
- Test connectivity: `ping 8.8.8.8`
- Test DNS: `nslookup google.com`

## Configuration Files Reference

Key configuration files to know:

| File | Purpose |
|------|---------|
| `/etc/ssh/sshd_config` | SSH server configuration |
| `/etc/hosts` | Static hostname resolution |
| `/etc/resolv.conf` | DNS resolver configuration |
| `/etc/fstab` | File system mount table |
| `/etc/sysctl.conf` | Kernel parameters |
| `/etc/systemd/` | Systemd configuration |
| `/etc/sudoers` | Sudo privileges (edit with `visudo`) |
| `/etc/security/` | Security policies |

## Learning Resources and Tutorials

Now that your system is configured, continue learning with these resources:

### Official OpenSUSE Documentation

**Start Here:**
- [OpenSUSE Leap Administration Guide](https://doc.opensuse.org/documentation/leap/archive/16.0/reference/html/book-reference/index.html) - Comprehensive system administration
- [OpenSUSE Security Guide](https://doc.opensuse.org/documentation/leap/security/html/book-security/index.html) - Security best practices
- [OpenSUSE System Analysis Guide](https://doc.opensuse.org/documentation/leap/tuning/html/book-tuning/index.html) - Performance tuning

### Linux Fundamentals

**Free Online Resources:**
- [Linux Journey](https://linuxjourney.com/) - Interactive Linux learning (beginner-friendly)
- [The Linux Command Line](http://linuxcommand.org/tlcl.php) - Free book on command line basics
- [OverTheWire: Bandit](https://overthewire.org/wargames/bandit/) - Learn Linux commands through games
- [Linux Survival](https://linuxsurvival.com/) - Interactive terminal tutorial

### SUSE-Specific Resources

- [OpenSUSE Wiki](https://en.opensuse.org/Portal:Wiki) - Community documentation
- [SUSE Documentation](https://documentation.suse.com/) - Enterprise SUSE docs (applicable to OpenSUSE)
- [OpenSUSE Forums](https://forums.opensuse.org/) - Community support

### Video Tutorials

- [Learn Linux TV (YouTube)](https://www.youtube.com/c/LearnLinuxtv) - Linux administration tutorials
- [The Linux Foundation Training](https://training.linuxfoundation.org/resources/) - Free resources and courses

### Books (Optional)

- **"The Linux Command Line"** by William Shotts (Free online)
- **"How Linux Works"** by Brian Ward - Understanding Linux internals
- **"UNIX and Linux System Administration Handbook"** by Evi Nemeth - Comprehensive reference

### Practice and Experimentation

**Safe ways to practice:**
1. **Hyper-V Checkpoints** - Take snapshots before experimenting
2. **Test commands with `--help`** - Most commands have built-in help
3. **Use `man` pages** - `man command-name` shows detailed documentation
4. **Break things!** - This is a learning VM, you can always restore or rebuild

### Next Learning Topics (After This Guide)

When you're ready to continue:
1. **Shell Scripting** - Automate tasks with bash scripts
2. **PostgreSQL Database** - Set up and learn SQL (coming in future guides)
3. **Web Server** - Install and configure nginx or Apache
4. **Plex Media Server** - Set up media streaming
5. **VoIP Lab** - Explore Asterisk and SIP concepts

## Quick Command Cheat Sheet

Save this for reference:

```bash
# System
hostnamectl                    # System info
timedatectl                    # Date/time info
uptime                         # System uptime
df -h                          # Disk usage
free -h                        # Memory usage

# Packages
sudo zypper update             # Update system
sudo zypper install <pkg>      # Install package
sudo zypper search <pkg>       # Search packages

# Services
sudo systemctl status <svc>    # Check service
sudo systemctl restart <svc>   # Restart service
sudo systemctl enable <svc>    # Enable at boot

# Logs
sudo journalctl -f             # Follow logs
sudo journalctl -u <svc>       # Service logs
sudo journalctl -p err         # Error logs only

# Network
ip addr show                   # IP addresses
sudo ss -tulpn                 # Listening ports
ping -c 4 <host>               # Test connectivity

# Files
ls -lah                        # List files (detailed)
chmod 755 <file>               # Change permissions
sudo chown user:group <file>   # Change owner

# Processes
ps aux                         # List processes
htop                           # Interactive viewer
kill <PID>                     # Stop process
```

## You're Ready!

Your SUSE Linux server is now fully configured and ready for use. You have:

✅ A functional OpenSUSE Leap 16.0 VM  
✅ Secure SSH access with key-based authentication  
✅ Hardened SSH configuration  
✅ Properly configured system settings  
✅ Essential tools installed  
✅ Links to comprehensive learning resources  

**What's next?** Take time to explore the tutorials above and practice basic Linux commands. When you're comfortable, you'll be ready to proceed with database setup and other projects.

## Next Steps (Future)

When ready to continue the project:

1. **PostgreSQL Database Setup** - Install and configure PostgreSQL (future guide)
2. **SQL Learning** - Work through the cocktail recipes database project (future guide)
3. **Plex Media Server** - Set up home media streaming (future guide)
4. **VoIP Lab** - Explore telephony concepts with Asterisk (future guide)

**For now:** Focus on becoming comfortable with the Linux command line and exploring the learning resources provided above.
