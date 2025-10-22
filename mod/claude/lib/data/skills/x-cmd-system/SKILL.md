---
name: x-cmd-system
description: Get system information using x-cmd including disk usage, process monitoring, file statistics, and PATH management. Use when user asks about disk space, running processes, file details, or system resources.
---

# x-cmd System Information

Retrieve system information with enhanced formatting using x-cmd.

## Commands Overview

### Disk Usage
```bash
x-cmd df
```
Shows disk space usage for all mounted filesystems with human-readable sizes and color coding.

### Process Monitoring
```bash
x-cmd ps
```
Shows running processes with enhanced filtering and sorting.

### File Statistics
```bash
x-cmd stat <file>
```
Shows detailed file/directory information (size, permissions, timestamps).

### PATH Management
```bash
x-cmd path
```
Shows current PATH environment variable in readable format.

### Enhanced Directory Listing
```bash
x-cmd ls [path]
```
Shows directory contents with colors, icons, and human-readable sizes.

## Common Scenarios

**Check Disk Space:**
```bash
x-cmd df
```
Highlight filesystems over 80% usage and available space.

**Find Resource-Heavy Processes:**
```bash
x-cmd ps
```
Look for high CPU/memory usage and long-running processes.

**Verify File Permissions:**
```bash
x-cmd stat script.sh
```

**Debug PATH Issues:**
```bash
x-cmd path
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `x-cmd df` | Disk space usage |
| `x-cmd ps` | Running processes |
| `x-cmd stat <file>` | File details |
| `x-cmd path` | PATH entries |
| `x-cmd ls [path]` | Directory listing |

## When to Use

- User asks about disk space or storage
- User wants to see running processes
- User needs file metadata or permissions
- User troubleshoots "command not found"
- User wants enhanced directory listing
