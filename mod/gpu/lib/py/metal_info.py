# shellcheck shell=dash
# Query GPU info via Python ctypes (Metal API + IOKit) on macOS.
# Outputs in the same "%-25s: %s" format as the shell-based output.
# Called by ___x_cmd_gpu_info_macos when python3 is available.
#
# Usage: python3 <this_file> [tty]

import ctypes, ctypes.util, subprocess, sys, json

tty = len(sys.argv) > 1 and sys.argv[1] == "1"

def fmtbytes(b):
    if b >= 1073741824: return f"{b / 1073741824:.0f} GB"
    if b >= 1048576:    return f"{b / 1048576:.0f} MB"
    if b >= 1024:       return f"{b / 1024:.0f} KB"
    return f"{b} B"

# Color mapping:
#   1;34 blue bold  — Metal caps (unified memory, buffers, features)
#   1;32 green bold — IOKit gpu cores
def p(k, v, color="1;34"):
    if v is None: return
    if tty:
        print(f"\033[{color}m%-25s\033[0m: %s" % (k, v))
    else:
        print(f"%-25s: %s" % (k, v))

objc = ctypes.CDLL(ctypes.util.find_library("objc"))
objc.objc_getClass.restype = ctypes.c_void_p
objc.sel_registerName.restype = ctypes.c_void_p
objc.objc_msgSend.restype = ctypes.c_void_p
objc.objc_msgSend.argtypes = [ctypes.c_void_p, ctypes.c_void_p]

def sel(name):
    return objc.sel_registerName(name.encode())

def msg(obj, method, *args, restype=ctypes.c_void_p):
    sig = [ctypes.c_void_p, ctypes.c_void_p]
    vals = [obj, sel(method)]
    for a in args:
        if isinstance(a, int):
            sig.append(ctypes.c_uint64)
        elif isinstance(a, float):
            sig.append(ctypes.c_double)
        else:
            sig.append(ctypes.c_void_p)
        vals.append(a)
    objc.objc_msgSend.restype = restype
    objc.objc_msgSend.argtypes = sig
    return objc.objc_msgSend(*vals)

def ns_to_str(obj):
    if not obj: return None
    r = msg(obj, "UTF8String", restype=ctypes.c_char_p)
    return r.decode("utf-8") if r else None

# ── Metal device caps ─────────────────────────────────────────────
try:
    metal = ctypes.CDLL(ctypes.util.find_library("Metal"))
    path_str = msg(objc.objc_getClass(b"NSString"), "stringWithUTF8String:",
                   b"/System/Library/Frameworks/Metal.framework")
    bundle = msg(objc.objc_getClass(b"NSBundle"), "bundleWithPath:", path_str)
    if bundle:
        msg(bundle, "load")

    metal.MTLCopyAllDevices.restype = ctypes.c_void_p
    metal.MTLCopyAllDevices.argtypes = []
    nsarray = metal.MTLCopyAllDevices()

    if nsarray:
        count = msg(nsarray, "count", restype=ctypes.c_uint64)
        for i in range(count):
            dev = msg(nsarray, "objectAtIndex:", i)

            # Metal capabilities — memory
            p("unified memory", msg(dev, "hasUnifiedMemory", restype=ctypes.c_bool))
            p("max working set",
              fmtbytes(msg(dev, "recommendedMaxWorkingSetSize", restype=ctypes.c_uint64)))
            p("max buffer length",
              fmtbytes(msg(dev, "maxBufferLength", restype=ctypes.c_uint64)))
            p("max threadgroup mem",
              fmtbytes(msg(dev, "maxThreadgroupMemoryLength", restype=ctypes.c_uint64)))

            # Metal capabilities — features
            p("raytracing", msg(dev, "supportsRaytracing", restype=ctypes.c_bool))
            p("mesh shaders", msg(dev, "supportsMeshShaders", restype=ctypes.c_bool))
            p("dynamic libraries", msg(dev, "supportsDynamicLibraries", restype=ctypes.c_bool))

            # Metal capabilities — specs
            p("max sampler count",
              msg(dev, "maxArgumentBufferSamplerCount", restype=ctypes.c_uint64))
except:
    pass

# ── IOKit gpu-core-count ──────────────────────────────────────────
try:
    iokit = ctypes.CDLL(ctypes.util.find_library("IOKit"))
    cf = ctypes.CDLL(ctypes.util.find_library("CoreFoundation"))

    iokit.IOServiceMatching.restype = ctypes.c_void_p
    iokit.IOServiceMatching.argtypes = [ctypes.c_char_p]
    iokit.IOServiceGetMatchingServices.restype = ctypes.c_int32
    iokit.IOServiceGetMatchingServices.argtypes = [ctypes.c_uint32, ctypes.c_void_p,
                                                     ctypes.POINTER(ctypes.c_uint32)]
    iokit.IOIteratorNext.restype = ctypes.c_uint32
    iokit.IOIteratorNext.argtypes = [ctypes.c_uint32]
    iokit.IOObjectRelease.restype = ctypes.c_int32
    iokit.IOObjectRelease.argtypes = [ctypes.c_uint32]
    iokit.IORegistryEntryCreateCFProperty.restype = ctypes.c_void_p
    iokit.IORegistryEntryCreateCFProperty.argtypes = [ctypes.c_uint32, ctypes.c_void_p,
                                                       ctypes.c_void_p, ctypes.c_uint32]

    cf.CFStringCreateWithCString.restype = ctypes.c_void_p
    cf.CFStringCreateWithCString.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_uint32]
    kCFStringEncodingUTF8 = 0x08000100
    cf.CFGetTypeID.restype = ctypes.c_uint64
    cf.CFGetTypeID.argtypes = [ctypes.c_void_p]
    cf.CFNumberGetTypeID.restype = ctypes.c_uint64
    cf.CFNumberGetTypeID.argtypes = []
    cf.CFNumberGetValue.restype = ctypes.c_bool
    cf.CFNumberGetValue.argtypes = [ctypes.c_void_p, ctypes.c_int32, ctypes.c_void_p]
    cf.CFRelease.argtypes = [ctypes.c_void_p]
    kCFNumberSInt64Type = 4
    number_typeid = cf.CFNumberGetTypeID()

    def cfstr(s):
        return cf.CFStringCreateWithCString(None, s, kCFStringEncodingUTF8)

    for service_name in [b"AGXAccelerator", b"IOGPUDevice"]:
        matching = iokit.IOServiceMatching(service_name)
        if not matching: continue
        iterator = ctypes.c_uint32(0)
        ret = iokit.IOServiceGetMatchingServices(ctypes.c_uint32(0), matching,
                                                  ctypes.byref(iterator))
        if ret != 0: continue

        while True:
            service = iokit.IOIteratorNext(iterator)
            if service == 0: break

            for prop in [b"gpu-core-count"]:
                cfkey = cfstr(prop)
                cfval = iokit.IORegistryEntryCreateCFProperty(service, cfkey, None, 0)
                cf.CFRelease(cfkey)
                if not cfval: continue
                tid = cf.CFGetTypeID(cfval)
                if tid == number_typeid:
                    val = ctypes.c_int64()
                    if cf.CFNumberGetValue(cfval, kCFNumberSInt64Type, ctypes.byref(val)):
                        p("gpu cores", val.value, "1;32")
                cf.CFRelease(cfval)

            iokit.IOObjectRelease(service)
        iokit.IOObjectRelease(iterator)
        break
except:
    pass
