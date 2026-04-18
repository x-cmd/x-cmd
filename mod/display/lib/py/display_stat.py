#!/usr/bin/env python3
"""macOS display stat: brightness, Night Shift via CoreDisplay/CoreBrightness."""
import ctypes
import ctypes.util
import sys
import struct

def fmt_pct(label, val, tty):
    """Format percentage with color."""
    val = max(0.0, min(1.0, val))
    pct = val * 100
    color = "1;32" if pct < 50 else ("1;33" if pct < 80 else "1;31")
    if tty:
        return f"\033[{color}m%-25s\033[0m: %.0f%%" % (label, pct)
    return "%-25s: %.0f%%" % (label, pct)

def get_brightness_macos(tty):
    """Get display brightness using CoreDisplay API."""
    try:
        cd = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreDisplay"))
    except Exception:
        return []

    results = []
    # Try display 1 (main display)
    display_id = 1
    try:
        brightness = cd.CoreDisplay_Display_GetUserBrightness(display_id)
        # CoreDisplay returns float, but the API may not be available on all versions
        if brightness >= 0:
            results.append(fmt_pct("brightness", brightness, tty))
    except Exception:
        pass

    return results

def get_main_display_id():
    """Get main display ID via CoreGraphics."""
    try:
        cg = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreGraphics"))
        main_id = cg.CGMainDisplayID()
        return main_id
    except Exception:
        return 1

def main():
    tty = sys.argv[1] if len(sys.argv) > 1 else ""
    tty = tty == "1"

    results = get_brightness_macos(tty)
    if results:
        for line in results:
            print(line)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
