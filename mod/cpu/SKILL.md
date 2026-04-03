---
name: x-cpu
description: |
  Display CPU information and detect system endianness.
  Shows model, cores, frequency, vendor, cache size.
  
  **Dependency**: This is an x-cmd module. Install x-cmd first (see x-cmd skill for installation options).
  see x-cmd skill for installation.

license: Apache-2.0
compatibility: POSIX Shell

metadata:
  author: Li Junhao
  version: "1.0.0"
  category: x-cmd-extension
  tags: [x-cmd, system, cpu, hardware]
---

# x cpu - CPU Information

> Display CPU information and detect system endianness.

---

## Quick Start

```bash
# Display CPU information (default)
x cpu

# Detect system endianness
x cpu endianness
```

---

## Features

- **CPU Info**: Display processor details (model, cores, MHz, vendor, cache)
- **Endianness Detection**: Detect system byte order (little/big endian)
- **Cross-platform**: Linux (via /proc/cpuinfo) and macOS (via sysctl)

---

## Commands

| Command | Description |
|---------|-------------|
| `x cpu` | Display CPU information (default) |
| `x cpu info` | Display CPU information |
| `x cpu endianness` | Detect system endianness (l/b) |

---

## Examples

### CPU Information

```bash
# Default - show CPU info
x cpu

# Linux output example:
# processor                : 0
# model name               : Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
# cpu cores                : 6
# cpu MHz                  : 2600.000
# vendor_id                : GenuineIntel
# cache size               : 12288 KB

# macOS output example:
# brand_string             : Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz
# core_count               : 6
# thread_count             : 12
# features                 : FPU VME DE PSE TSC MSR PAE MCE CX8 APIC SEP MTRR PGE MCA CMOV PAT PSE36 CLFSH DS ACPI MMX FXSR SSE SSE2 SS HTT TM PBE SSE3 PCLMULQDQ DTES64 MON DSCPL VMX EST TM2 SSSE3 FMA CX16 TPR PDCM SSE4.1 SSE4.2 x2APIC MOVBE POPCNT AES PCID XSAVE OSXSAVE SEGLIM64 TSCTMR AVX1.0 RDRAND F16C
```

### Endianness Detection

```bash
# Detect byte order
x cpu endianness

# Output: l (little-endian) or b (big-endian)
```

---

## Platform Notes

### Linux
- Reads from `/proc/cpuinfo`
- Shows: processor, model name, cpu cores, cpu MHz, vendor_id, cache size

### macOS
- Uses `sysctl machdep.cpu`
- Shows: brand_string, core_count, thread_count, features

---

## About Endianness

| Value | Meaning |
|-------|---------|
| `l` | Little-endian (x86, x86_64, ARM) |
| `b` | Big-endian (some MIPS, PowerPC, SPARC) |

Most modern systems use little-endian byte order.

---

## Related

- Linux `/proc/cpuinfo` documentation
- macOS `sysctl` manual page
