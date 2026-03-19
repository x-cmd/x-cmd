# China Region Network Acceleration Guide

> How to configure x-cmd for optimal network access in China region

---

## Quick Detection & Configuration

```bash
# 1. Detect if in China region
x websrc testcn

# 2. Set x-cmd China channel (recommended)
x websrc set cn

# 3. Configure package manager mirrors
x apt mirror set tuna      # Debian/Ubuntu
x dnf mirror set tuna      # Fedora/RHEL
x npm mirror set ali       # Node.js/NPM
```

---

## Detect Current Network Region

```bash
x websrc testcn
```

- Returns `0` (true): Located in China region
- Returns `1` (false): Located overseas

## Switch Channels

| Command | Description |
|---------|-------------|
| `x websrc set cn` | Switch to China channel, use domestic CDN |
| `x websrc set inet` | Switch to international channel |
| `x websrc set internet` | Same as `inet` |
| `x websrc set net` | Same as `inet` |
| `x websrc get` | View current configuration |

Once configured, x-cmd will use **China region hosted network** for accelerated distribution, covering the following resources:

| Module | Description |
|--------|-------------|
| `x env use <pkg>` | Software package download and installation |
| `x theme` | Theme resources download |
| `x advise` | Command completion data |
| `x tldr` | TLDR help documents |
| `x ccal` | Calendar system data |
| `x pkg` | All module resource downloads |

> In short, all resources that x-cmd needs to download remotely (scripts, data, documents, etc.) will be accelerated through the China region channel.

---

## System Package Manager Mirrors

### APT (Debian/Ubuntu)

```bash
x apt mirror set tuna
```

Available mirrors: `ali`, `tuna`, `bfsu`, `ustc`, `tencent`

### DNF (Fedora/RHEL)

```bash
x dnf mirror set tuna
```

Available mirrors: `ali`, `huawei`, `tuna`, `ustc`, `bfsu`

### YUM (CentOS/RHEL)

```bash
x yum mirror set tuna
```

Available mirrors: `ali`, `tuna`, `ustc`

### APK (Alpine)

```bash
x apk mirror set ali
```

Available mirrors: `ali`, `huawei`, `tuna`, `ustc`, `sjtu`, `official`

### Pacman (Arch Linux)

```bash
x pacman mirror set tuna
```

Available mirrors: `ali`, `tuna`, `ustc`, `bfsu`, `sjtu`

### Homebrew (macOS/Linux)

```bash
x brew mirror set tuna
```

Available mirrors: `ali`, `tuna`, `ustc`, `bfsu`, `sjtu`, `official`

---

## Language Package Manager Mirrors

### NPM (Node.js)

```bash
x npm mirror set ali
```

Available mirrors: `npmmirror` (default), `tencent`, `huawei`, `official`

### PNPM

```bash
x pnpm mirror set ali
```

Available mirrors: `npmmirror` (default), `tencent`, `huawei`, `official`

### Yarn

```bash
x yarn mirror set ali
```

Available mirrors: `npmmirror` (default), `tencent`, `huawei`, `official`

### Pip (Python)

```bash
x pip mirror set ali
```

Available mirrors: `ali` (default), `tuna`, `ustc`, `bfsu`, `sjtu`, `hust`, `huawei`, `wangyi`

### Go

```bash
x go mirror set ali
```

Available mirrors: `ali` (default), `tencent`, `huawei`, `goproxy.cn`, `goproxy.io`, `official`

### Cargo (Rust)

```bash
x cargo mirror set tuna
```

Available mirrors: `ali` (default), `tuna`, `ustc`, `bfsu`, `sjtu`, `hust`

### Gem (Ruby)

```bash
x gem mirror set ali
```

Available mirrors: `ali` (default), `tuna`, `ustc`, `bfsu`, `huawei`, `official`

---

## Docker Image Acceleration

Pull base images from AWS ECR (supports ubuntu, debian, alpine, etc.):

```bash
x docker ecpull ubuntu:22.04
x docker ecpull debian:12
x docker ecpull alpine:latest
```

Use cases:
- China users: Bypass Docker Hub access restrictions
- Overseas users: Bypass Docker Hub rate limits

---

## Complete Configuration Example

```bash
# Detect and configure China acceleration
if x websrc testcn; then
    x websrc set cn
    
    # System package managers
    x apt mirror set tuna 2>/dev/null || true      # Debian/Ubuntu
    x dnf mirror set tuna 2>/dev/null || true      # Fedora/RHEL
    x yum mirror set tuna 2>/dev/null || true      # CentOS/RHEL
    x apk mirror set ali 2>/dev/null || true       # Alpine
    x pacman mirror set tuna 2>/dev/null || true   # Arch Linux
    x brew mirror set tuna 2>/dev/null || true     # macOS/Linux
    
    # Language package managers
    x npm mirror set ali 2>/dev/null || true       # Node.js
    x pnpm mirror set ali 2>/dev/null || true      # PNPM
    x yarn mirror set ali 2>/dev/null || true      # Yarn
    x pip mirror set ali 2>/dev/null || true       # Python
    x go mirror set ali 2>/dev/null || true        # Go
    x cargo mirror set tuna 2>/dev/null || true    # Rust
    x gem mirror set ali 2>/dev/null || true       # Ruby
    
    echo "China region acceleration configured"
fi
```

---

## Related Links

- [x-cmd Official Website](https://www.x-cmd.com)
- [x-cmd Documentation](https://x-cmd.com/llms.txt)
