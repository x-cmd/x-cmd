# Detect CPU frequency on Apple Silicon via IOKit pmgr voltage-states.
# Reads voltage-states5-sram (P-cores) and voltage-states1-sram (E-cores).
# Same algorithm as fastfetch cpu_apple.c detectFrequency().
# Outputs in "%-25s: %s" format.
# Usage: python3 <this_file> [tty]

import ctypes, ctypes.util, struct, sys

tty = len(sys.argv) > 1 and sys.argv[1] == "1"

def p(k, v, color="1;35"):
    if v is None: return
    if tty:
        print(f"\033[{color}m%-25s\033[0m: %s" % (k, v))
    else:
        print(f"%-25s: %s" % (k, v))

def fmtmhz(mhz):
    if mhz >= 1000:
        return f"{mhz / 1000:.2f} GHz"
    return f"{mhz:.0f} MHz"

def extract_max_freq_mhz(data):
    """Extract max frequency from voltage-states data (pairs of uint32).
    Returns frequency in MHz or None."""
    if len(data) < 8 or len(data) % 8 != 0:
        return None
    vals = struct.unpack('<' + 'I' * (len(data) // 4), data)
    pmax = 0
    # Even indices are frequency values, odd are voltage (skipped)
    for i in range(0, len(vals), 2):
        if vals[i] > pmax:
            pmax = vals[i]
    if pmax == 0:
        return None
    # fastfetch heuristic: >100M means Hz (M1-M3), else kHz (M4+)
    if pmax > 100000000:
        return pmax // 1000 // 1000
    else:
        return pmax // 1000

try:
    iokit = ctypes.CDLL(ctypes.util.find_library("IOKit"))
    cf = ctypes.CDLL(ctypes.util.find_library("CoreFoundation"))

    iokit.IOServiceGetMatchingService.restype = ctypes.c_uint32
    iokit.IOServiceGetMatchingService.argtypes = [ctypes.c_uint32, ctypes.c_void_p]
    iokit.IOServiceNameMatching.restype = ctypes.c_void_p
    iokit.IOServiceNameMatching.argtypes = [ctypes.c_char_p]
    iokit.IORegistryEntryCreateCFProperty.restype = ctypes.c_void_p
    iokit.IORegistryEntryCreateCFProperty.argtypes = [ctypes.c_uint32, ctypes.c_void_p,
                                                       ctypes.c_void_p, ctypes.c_uint32]
    cf.CFDataGetLength.restype = ctypes.c_int64
    cf.CFDataGetLength.argtypes = [ctypes.c_void_p]
    cf.CFDataGetBytePtr.restype = ctypes.c_void_p
    cf.CFDataGetBytePtr.argtypes = [ctypes.c_void_p]
    cf.CFRelease.argtypes = [ctypes.c_void_p]

    # Build CFSTR for property names
    cf.CFStringCreateWithCString.restype = ctypes.c_void_p
    cf.CFStringCreateWithCString.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_uint32]
    kCFStringEncodingUTF8 = 0x08000100

    def cfstr(s):
        return cf.CFStringCreateWithCString(None, s, kCFStringEncodingUTF8)

    def cfstr_ref(s):
        return cf.CFStringCreateWithCString(None, s, kCFStringEncodingUTF8)

    # Find pmgr service
    matching = iokit.IOServiceNameMatching(b"pmgr")
    if not matching:
        sys.exit(0)
    entry = iokit.IOServiceGetMatchingService(ctypes.c_uint32(0), matching)
    if entry == 0:
        sys.exit(0)

    # Read voltage-states5-sram (P-cores)
    pcore_mhz = None
    try:
        cfkey = cfstr(b"voltage-states5-sram")
        prop = iokit.IORegistryEntryCreateCFProperty(entry, cfkey, None, 0)
        cf.CFRelease(cfkey)
        if prop:
            length = cf.CFDataGetLength(prop)
            ptr = cf.CFDataGetBytePtr(prop)
            if ptr and length > 0:
                data = (ctypes.c_ubyte * length).from_address(ptr)
                pcore_mhz = extract_max_freq_mhz(bytes(data))
            cf.CFRelease(prop)
    except:
        pass

    # Read voltage-states1-sram (E-cores)
    ecore_mhz = None
    try:
        cfkey = cfstr(b"voltage-states1-sram")
        prop = iokit.IORegistryEntryCreateCFProperty(entry, cfkey, None, 0)
        cf.CFRelease(cfkey)
        if prop:
            length = cf.CFDataGetLength(prop)
            ptr = cf.CFDataGetBytePtr(prop)
            if ptr and length > 0:
                data = (ctypes.c_ubyte * length).from_address(ptr)
                ecore_mhz = extract_max_freq_mhz(bytes(data))
            cf.CFRelease(prop)
    except:
        pass

    iokit.IOObjectRelease(entry)

    if pcore_mhz:
        p("cpu max frequency", fmtmhz(pcore_mhz))
    if ecore_mhz:
        p("cpu efficiency max freq", fmtmhz(ecore_mhz))

except:
    pass
