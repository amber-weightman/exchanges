# Linux SUSE Distributions Explained

## Summary

- **Sydney Trains uses:** SLES 15 SP4/SP5/SP6 (most likely)
- **We're using:** OpenSUSE Leap 16.0 (latest stable)
- **Why:** Easily accessible, modern tooling, skills 100% transferable to SLES 15, earler versions no longer easily available
- **Trade-off:** Newer than current enterprise deployments, but fundamentals are identical

## Why This Matters

Understanding which SUSE distribution to use is important for matching the learning environment to real-world NSW Government (Sydney Trains) infrastructure.

## Distribution Options

### SUSE Linux Enterprise Server (SLES)
**What it is:**
- Commercial enterprise Linux distribution from SUSE
- Paid product with enterprise support contracts
- Used by government, large corporations, and critical infrastructure
- Long-term support (10+ years)
- Current version: SLES 15 (with Service Packs - currently SP6)

**Why governments use it:**
- Certified support and compliance
- Security patches and updates guaranteed
- Vendor accountability
- Long support lifecycle matches government procurement cycles

**Reality check:**
- Government agencies typically run 1-2 versions behind current release for stability
- Sydney Trains likely uses SLES 15 SP4, SP5, or SP6 (not the newest)
- Upgrading in government requires lengthy approval and testing

---

### OpenSUSE Leap
**What it is:**
- Free, community-supported distribution
- Based on SLES codebase (~90% package overlap)
- Binary-compatible with SLES
- Same package manager (`zypper`), same tools, same structure

**Why we chose OpenSUSE Leap 16.0:**
- Latest stable release (December 2024)
- Pre-built VM images available (fast setup)
- Modern tooling and up-to-date packages
- No registration or licensing required
- Free to download and use
- Ideal for learning skills directly transferable to SLES

**Version consideration:**
- Leap 16.0 is newer than current enterprise SLES 15 deployments
- However, **core system administration skills should be identical**:
  - Package management (`zypper`)
  - systemd service management
  - Firewall configuration
  - User/permission management
  - File system structure
- Learning on 16.0 doesn't diminish relevance to SLES 15
- Added benefit: Experience with newer features and improvements

**Why not Leap 15.6?**
- Leap 15.6 mirrors SLES 15 SP6 more closely
- However, it's not readily available, as a pre-built VM or a legacy download version
- Manual ISO installation required (adds friction to getting started)
- For this learning project, fast setup > version precision

---

### OpenSUSE Tumbleweed
**What it is:**
- Rolling release (constantly updated)
- Always has the latest software versions

**Why we're NOT using it:**
- Completely different model from SLES
- Not representative of enterprise environments
- Government systems prioritize stability over cutting-edge features

## Our Choice: OpenSUSE Leap 16.0

**Reasons:**
1. **Easily accessible** - Pre-built VM images available for immediate use
2. **Fast setup** - Skip manual OS installation, focus on learning operations
3. **Free and modern** - Latest stable features with no licensing barriers
4. **Directly transferable skills** - Commands, tools, and concepts map directly to SLES
5. **Well-documented** - Active community, current documentation

## Key Point: What You Learn Transfers

Everything you learn on OpenSUSE Leap 16.0 applies directly to SLES 15 (and future SLES 16):
- Package management (`zypper`)
- systemd service management
- Firewall (`firewalld` or `SuSEfirewall2`)
- File system layout
- Configuration file locations
- Log management
- User and permission management

The differences are purely licensing, support contracts, and branding.

--- 
---

## Alternative: SLES Developer License

If you want to work with actual SLES for maximum accuracy, a free developer license can be obtained.

### Why Use SLES Instead of OpenSUSE?

If you want to work with the **exact** distribution used in enterprise environments (including NSW Government), SLES provides:
- Identical packages and configuration to production systems
- Experience with SUSE's official registration and licensing system
- Practice with SUSE Customer Center (SCC) workflows
- Most accurate representation of workplace systems

**Trade-off:** More setup overhead vs. OpenSUSE's "just download and go"

### SLES License Options

#### Option 1: SLES Developer Subscription (Recommended)
**Free for development and testing purposes**

**What you get:**
- SLES 15 (latest service pack)
- Full access to repositories and updates
- Registration with SUSE Customer Center
- Suitable for learning, development, and non-production use

**Limitations:**
- Not for production use
- Limited to development/testing

**How to obtain:**
1. Visit [SUSE Developer Program](https://www.suse.com/developer/)
2. Create a free SUSE account
3. Navigate to "Free Developer Subscription"
4. Register for the developer program
5. Receive registration code via email
6. Download SLES from the developer portal

#### Option 2: SLES Evaluation/Trial
**60-day evaluation without registration**

**Available at:** https://www.suse.com/download/sles/

**What you get:**
- SLES 15 SP6 (or current version)
- Full functionality for 60 days
- No SUSE account required initially
- Can be converted to registered/licensed version later

**Limitations:**
- 60-day evaluation period
- Must register or reinstall after expiration

**Note:** The download page allows you to download the ISO immediately, but you'll need to register within 60 days to continue receiving updates.

### Download and Installation

#### Step 1: Download SLES ISO

**Via SUSE Developer Program (after registration):**
1. Log in to [SUSE Customer Center](https://scc.suse.com/)
2. Navigate to "Products" → "SUSE Linux Enterprise Server"
3. Select version: SLES 15 SP6
4. Download the installation ISO

**Via Evaluation Download (no registration required initially):**
1. Visit https://www.suse.com/download/sles/
2. Select "SUSE Linux Enterprise Server 15 SP6"
3. Click "Download" 
4. Save ISO to: `Z:\ISOs\SLE-15-SP6-Full-x86_64-GM-Media1.iso`

**ISO size:** Approximately 4-5 GB

#### Step 2: Verify ISO (Optional)

```powershell
# Verify the downloaded ISO checksum
Get-FileHash "Z:\ISOs\SLE-15-SP6-Full-x86_64-GM-Media1.iso" -Algorithm SHA256
```

Compare with checksum provided on download page.

#### Step 3: Create VM

Use the same VM creation script as for OpenSUSE, but specify the SLES ISO:

```powershell
.\scripts\setup\01-create-vm.ps1 -IsoPath "Z:\ISOs\SLE-15-SP6-Full-x86_64-GM-Media1.iso"
```

#### Step 4: Install SLES

Follow the installation guide in [doc/02-vm-installation.md](02-vm-installation.md) - the process is identical to OpenSUSE.

#### Step 5: Register Your System

**During installation:**
- When prompted for registration, enter your registration code (from developer program email)
- Or skip and register later

**After installation (via SSH or console):**

```bash
# Register with SUSE Customer Center
sudo SUSEConnect -r YOUR_REGISTRATION_CODE -e your.email@example.com

# Or for evaluation without registration (60 days)
# No registration needed - system works immediately
```

**To check registration status:**
```bash
sudo SUSEConnect --status
```

#### Step 6: Enable Repositories

After registration, enable the repositories you need:

```bash
# List available extensions/modules
sudo SUSEConnect --list-extensions

# Example: Enable Development Tools module
sudo SUSEConnect -p sle-module-development-tools/15.6/x86_64

# Example: Enable Python 3 module
sudo SUSEConnect -p sle-module-python3/15.6/x86_64
```

### Differences from OpenSUSE Leap

**Registration:**
- SLES requires SUSEConnect registration for updates
- OpenSUSE Leap does not require registration

**Repositories:**
- SLES uses SCC (SUSE Customer Center) repositories
- OpenSUSE uses community mirror repositories

**Support:**
- SLES includes official support (if purchased/enterprise license)
- Developer license: no official support, but access to updates

**Package availability:**
- Nearly identical for core system packages
- SLES may have some enterprise-specific packages
- OpenSUSE may have more community packages readily available

### When to Use SLES vs. OpenSUSE

**Use SLES if:**
- You want exact enterprise environment match
- You plan to practice SCC registration workflows
- You want experience with enterprise licensing
- You're preparing for workplace system administration

**Use OpenSUSE Leap if:**
- You want to start learning immediately
- You prefer simpler setup
- Registration overhead is unwanted
- Skills learned are sufficient (98% identical)

### Converting This Setup

If you start with OpenSUSE and later want SLES:
1. Back up any configuration/scripts you've created
2. Create a new VM with SLES ISO
3. Restore your configurations
4. The system administration commands are identical

### Support Resources

- [SUSE Documentation](https://documentation.suse.com/)
- [SUSE Developer Portal](https://www.suse.com/developer/)
- [SUSEConnect Command Guide](https://documentation.suse.com/sles/15-SP6/html/SLES-all/cha-register-sle.html)
- [SUSE Customer Center](https://scc.suse.com/)

