---
name: qr
description: |
  QR code generation — terminal display, PNG output, pure shell encoding.
  Zero barrier — use with x-cmd, Python qrcode, or any QR library.
  Use for "qr", "qrcode", "barcode", "encode".

metadata:
  version: "0.1.0"
  category: encoding
  tags: [qr, qrcode, barcode, encode, terminal]
  repository: https://github.com/x-cmd/skill0
  type: skill0
---

# qr — skill0

Generate QR codes from text or URLs. Terminal display, PNG output, or pure shell encoding.

## Quick Start

```bash
# With x-cmd
x qr "Hello World"                   # Terminal QR code
x qr "https://example.com"           # URL to QR

# Without x-cmd — use Python
pip install qrcode
python3 -c "import qrcode; qrcode.make('Hello').save('qr.png')"

# Or use online API
curl -s "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=Hello" -o qr.png
```

## What's Available

| Mode | Description |
|------|-------------|
| Terminal | Display QR in terminal |
| PNG | Generate PNG file |
| Pure shell | AWK-based encoding (no deps) |

## This skill0 grows

Starting with the essentials. Will add:
- QR encoding algorithms
- Error correction levels
- WiFi QR format
