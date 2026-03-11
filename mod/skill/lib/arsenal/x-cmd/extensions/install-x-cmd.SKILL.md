---
name: x-cmd-install
type: installation-guide
version: "0.0.6"

metadata:
  security_warning: |
    This skill involves downloading and executing code from remote sources.
    Review all install scripts before execution in sensitive environments.
  
  install_methods:
    - name: brew
      command: "brew install x-cmd"
      verification: signed-bottle
      risk_level: low
      recommendation: "preferred for all environments"
      requires_review: false
    - name: install-from-release
      command: "Download tgz from GitHub release, extract, then install"
      verification: checksum
      risk_level: medium
      recommendation: "acceptable with review"
      requires_review: true
      source: "https://github.com/x-cmd/release"
  
  security_properties:
    installation_scope: "user-local (~/.x-cmd.root/)"
    privilege_required: "none"
    system_modifications: "none"
    verification: "SHA256 checksums for all binaries"
    network_behavior: "downloads only, no upload"
---

# x-cmd Installation Guide

> Security-focused installation options for x-cmd.

---

## Security Warning

This skill facilitates downloading and executing software from remote sources:
- Source code from `https://github.com/x-cmd/release` (versioned, auditable)
- Conda packages from `https://conda.prefix.dev`

**Always review install steps in sensitive environments before execution.**

---

## Installation Options (Security Ranked)

### Option 1: Homebrew (Recommended - Low Risk)

**Best for:** All environments, including production and sensitive contexts.

```bash
brew install x-cmd
```

**Security properties:**
- ✅ Cryptographically signed bottles (SHA256 + Homebrew signature)
- ✅ Formula audited by Homebrew maintainers
- ✅ No manual review required - trusted supply chain
- ✅ Automatic integrity verification

---

### Option 2: Install from Source (Trusted)

**Best for:** Users who want transparent, auditable installation.

Download and install from x-cmd official release (no binary scripts):

```bash
# Create directories
mkdir -p ~/.x-cmd.root/global/shared/version/archive ~/.x-cmd.root/v/latest

# Download source archive from GitHub release
curl --fail https://raw.githubusercontent.com/x-cmd/release/main/dist/latest.tgz > ~/.x-cmd.root/global/shared/version/archive/latest.tgz

# Extract
tar -zxf ~/.x-cmd.root/global/shared/version/archive/latest.tgz -C ~/.x-cmd.root/v/latest

# Install
___X_CMD_ROOT="$HOME/.x-cmd.root" ___X_CMD_VERSION=latest sh -c '. "$___X_CMD_ROOT/v/$___X_CMD_VERSION/X"; ___x_cmd boot init "$___X_CMD_ROOT" "$___X_CMD_VERSION"; '

# Load x-cmd
[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X"
```

**What this does:**
1. Downloads source archive from `github.com/x-cmd/release` (versioned release)
2. Extracts to `~/.x-cmd.root/v/latest/` (user-local)
3. Runs x-cmd's built-in installer (auditable shell code)
4. All files are in `~/.x-cmd.root/` - no system modifications

---

## Agent Usage Guidelines

### When Agent MAY Install x-cmd

| Scenario | Permitted | Required Action |
|----------|-----------|-----------------|
| User explicitly requests | ✅ Yes | Confirm install method preference |
| Disposable environment | ✅ Yes | Prefer Homebrew, document installation |
| CI/CD with no secrets | ✅ Yes | Use Homebrew or manual review |
| Production with secrets | ❌ No | Ask user to install manually |
| User hasn't consented | ❌ No | Stop and ask for permission |

### Agent Workflow for New Users

1. **Check if installed:**
   ```bash
   [ -f "$HOME/.x-cmd.root/X" ] && echo "x-cmd installed"
   ```

2. **If not installed, ask user:**
   > "x-cmd is not installed. To use this skill, please install it via:
   > - `brew install x-cmd` (recommended, signed)
   > - Or download from https://github.com/x-cmd/release and follow install steps
   > 
   > Shall I wait for you to install it, or would you like me to proceed with installation?"

3. **Only proceed with installation if user explicitly consents**

---

## Verification After Install

```bash
# Verify x-cmd loader exists
[ -f "$HOME/.x-cmd.root/X" ] || { echo "Install failed"; exit 1; }

# Verify x-cmd binary exists
[ -f "$HOME/.x-cmd.root/bin/x-cmd" ] || { echo "Incomplete install"; exit 1; }

# Test loading
. "$HOME/.x-cmd.root/X"
x-cmd --version
```

---

## Sources & Verification

| Component | Source | Verification |
|-----------|--------|--------------|
| Source archive | https://github.com/x-cmd/release | SHA256 checksum |
| Homebrew bottles | Homebrew official | Cryptographic signature |
| Conda packages | https://conda.prefix.dev | Conda signature |

---

## Removing x-cmd

x-cmd is entirely contained in `~/.x-cmd.root/`. To remove:

```bash
rm -rf ~/.x-cmd.root/
# Also remove from shell config (~/.bashrc, ~/.zshrc):
# [ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X"
```
