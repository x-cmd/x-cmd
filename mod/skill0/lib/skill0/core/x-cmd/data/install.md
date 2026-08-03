# x-cmd Installation Guide

> Security-focused installation options for x-cmd.

---

## Security Warning

This skill facilitates downloading and executing software from remote sources:
- Install script from `https://get.x-cmd.com`
- Binary packages from `https://github.com/x-cmd/release`
- Conda packages from `https://conda.prefix.dev`

**Always review install scripts in sensitive environments before execution.**

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

### Option 2: Manual Install with Review (Medium Risk)

**Best for:** Users who want to audit code before execution.

```bash
# 1. Download install script
curl -fsSL https://get.x-cmd.com > /tmp/x-cmd-install.sh

# 2. REVIEW the script content (critical step)
cat /tmp/x-cmd-install.sh
# Or: less /tmp/x-cmd-install.sh

# 3. Execute only after satisfactory review
sh /tmp/x-cmd-install.sh
```

**What the script does:**
1. Creates `~/.x-cmd.root/` directory (user-local)
2. Downloads x-cmd core files from GitHub releases
3. Verifies SHA256 checksums of all downloaded files
4. No system modifications, no sudo required

---

### Option 3: Auto-Install (High Risk - Avoid in Sensitive Environments)

**⚠️ WARNING:** This executes remote code without manual review.

```bash
curl -fsSL https://get.x-cmd.com | sh
```

**Only use when:**
- Environment is disposable (container, temporary VM)
- No sensitive credentials in environment
- User explicitly accepts the risk

**Security implications:**
- ❌ No opportunity to review code before execution
- ❌ Vulnerable to supply chain attacks if get.x-cmd.com is compromised
- ⚠️ Checksum verification happens AFTER initial script execution

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
   > - Or download from https://get.x-cmd.com and review before executing
   > 
   > Shall I wait for you to install it, or would you like me to proceed with installation?"

3. **Only proceed with auto-install if user explicitly consents**

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
| Install script | https://get.x-cmd.com | User review + HTTPS |
| Core binaries | https://github.com/x-cmd/release | SHA256 checksum |
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

---

Parent skill: [../SKILL.md](../SKILL.md)
