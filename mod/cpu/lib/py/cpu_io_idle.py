# Query per-cluster (E/P) idle residency on Apple Silicon via libIOReport.
#
# This is a private/undocumented API (libIOReport.dylib, not in public SDK).
# Goal: best-effort enhancement — when it works, append two lines (ecpu/pcpu idle).
# When anything fails (API change, channel renamed, dylib missing, etc.), this
# script silently exits without output, leaving the existing user/sys/nice output
# from cpu_stat.py completely untouched.
#
# Output format matches cpu_stat.py: "%-25s: %s"
# Usage: python3 <this_file> [tty]

import ctypes
import sys


tty = len(sys.argv) > 1 and sys.argv[1] == "1"


def p(k, v, color="0"):
    if tty:
        print(f"\033[{color}m%-25s\033[0m: %s" % (k, v))
    else:
        print("%-25s: %s" % (k, v))


def main():
    # ── Load libraries (silently fail if anything is wrong) ────────
    try:
        libIOReport = ctypes.CDLL("/usr/lib/libIOReport.dylib")
        cf = ctypes.CDLL("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
    except OSError:
        return  # dylib missing or unloadable — silent

    # ── CF type IDs ─────────────────────────────────────────────────
    try:
        for name in ("CFStringGetTypeID", "CFNumberGetTypeID",
                     "CFDictionaryGetTypeID", "CFArrayGetTypeID"):
            f = getattr(cf, name)
            f.argtypes = []
            f.restype = ctypes.c_ulong
        CFStringGetTypeID  = cf.CFStringGetTypeID()
        CFNumberGetTypeID  = cf.CFNumberGetTypeID()
        CFDictionaryGetTypeID = cf.CFDictionaryGetTypeID()
        CFArrayGetTypeID   = cf.CFArrayGetTypeID()
    except Exception:
        return

    # ── CF function prototypes ─────────────────────────────────────
    try:
        cf.CFDictionaryGetCount.argtypes = [ctypes.c_void_p]
        cf.CFDictionaryGetCount.restype  = ctypes.c_long
        cf.CFDictionaryGetKeysAndValues.argtypes = [
            ctypes.c_void_p,
            ctypes.POINTER(ctypes.c_void_p),
            ctypes.POINTER(ctypes.c_void_p),
        ]
        cf.CFDictionaryGetKeysAndValues.restype = None
        cf.CFArrayGetCount.argtypes = [ctypes.c_void_p]
        cf.CFArrayGetCount.restype  = ctypes.c_long
        cf.CFArrayGetValueAtIndex.argtypes = [ctypes.c_void_p, ctypes.c_long]
        cf.CFArrayGetValueAtIndex.restype  = ctypes.c_void_p
        cf.CFStringGetLength.argtypes = [ctypes.c_void_p]
        cf.CFStringGetLength.restype  = ctypes.c_long
        cf.CFStringGetCString.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                           ctypes.c_long, ctypes.c_uint32]
        cf.CFStringGetCString.restype  = ctypes.c_bool
        cf.CFNumberGetValue.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
        cf.CFNumberGetValue.restype  = ctypes.c_bool
        cf.CFGetTypeID.argtypes = [ctypes.c_void_p]
        cf.CFGetTypeID.restype  = ctypes.c_ulong
        cf.CFRelease.argtypes = [ctypes.c_void_p]
        cf.CFRelease.restype  = None

        kCFNumberSInt64Type = 4
        kCFStringEncodingUTF8 = 0

        # IOReport prototypes
        libIOReport.IOReportCopyAllChannels.argtypes = [ctypes.c_void_p]
        libIOReport.IOReportCopyAllChannels.restype  = ctypes.c_void_p
        libIOReport.IOReportCreateSubscription.argtypes = [
            ctypes.c_void_p,
            ctypes.c_void_p,
            ctypes.POINTER(ctypes.c_void_p),
            ctypes.c_uint64,
            ctypes.c_void_p,
        ]
        libIOReport.IOReportCreateSubscription.restype = ctypes.c_void_p
        libIOReport.IOReportCreateSamples.argtypes = [
            ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p,
        ]
        libIOReport.IOReportCreateSamples.restype = ctypes.c_void_p
        libIOReport.IOReportCreateSamplesDelta.argtypes = [
            ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p,
        ]
        libIOReport.IOReportCreateSamplesDelta.restype = ctypes.c_void_p
        libIOReport.IOReportSimpleGetIntegerValue.argtypes = [
            ctypes.c_void_p, ctypes.c_int32,
        ]
        libIOReport.IOReportSimpleGetIntegerValue.restype = ctypes.c_int64
    except Exception:
        return

    def cf_to_python(obj):
        if not obj:
            return None
        try:
            t = cf.CFGetTypeID(obj)
        except Exception:
            return None
        if t == CFStringGetTypeID:
            try:
                length = cf.CFStringGetLength(obj) + 1
                buf = ctypes.create_string_buffer(length)
                if cf.CFStringGetCString(obj, buf, length, kCFStringEncodingUTF8):
                    return buf.value.decode("utf-8")
            except Exception:
                return None
            return None
        if t == CFNumberGetTypeID:
            try:
                out = ctypes.c_int64(0)
                if cf.CFNumberGetValue(obj, kCFNumberSInt64Type, ctypes.byref(out)):
                    return out.value
            except Exception:
                return None
            return None
        if t == CFDictionaryGetTypeID:
            try:
                count = cf.CFDictionaryGetCount(obj)
                if count == 0:
                    return {}
                keys = (ctypes.c_void_p * count)()
                vals = (ctypes.c_void_p * count)()
                cf.CFDictionaryGetKeysAndValues(obj, keys, vals)
                out = {}
                for i in range(count):
                    k = cf_to_python(keys[i])
                    v = cf_to_python(vals[i])
                    if k is not None:
                        out[k] = v
                return out
            except Exception:
                return None
        if t == CFArrayGetTypeID:
            try:
                n = cf.CFArrayGetCount(obj)
                return [cf_to_python(cf.CFArrayGetValueAtIndex(obj, i)) for i in range(n)]
            except Exception:
                return None
        return None

    def get_dict_array_value(cf_dict, key):
        try:
            count = cf.CFDictionaryGetCount(cf_dict)
            keys = (ctypes.c_void_p * count)()
            vals = (ctypes.c_void_p * count)()
            cf.CFDictionaryGetKeysAndValues(cf_dict, keys, vals)
            for i in range(count):
                if cf_to_python(keys[i]) == key:
                    return vals[i]
        except Exception:
            return None
        return None

    # ── 1. Get all channels ───────────────────────────────────────
    try:
        all_channels = libIOReport.IOReportCopyAllChannels(None)
        if not all_channels:
            return
    except Exception:
        return

    try:
        try:
            cpu_arr_cf = get_dict_array_value(all_channels, "IOReportChannels")
            if not cpu_arr_cf:
                return

            # Walk CPU channels; collect (name, cf_ref) for "CPU Stats" only
            cpu_refs = []
            n = cf.CFArrayGetCount(cpu_arr_cf)
            for i in range(n):
                try:
                    ch_cf = cf.CFArrayGetValueAtIndex(cpu_arr_cf, i)
                    ch = cf_to_python(ch_cf)
                    if not ch or ch.get("IOReportGroupName") != "CPU Stats":
                        continue
                    legend = ch.get("LegendChannel", [])
                    if len(legend) >= 3:
                        name = (legend[2] or "").strip()
                        cpu_refs.append((name, ch_cf))
                except Exception:
                    continue

            # ── 2. Subscribe ───────────────────────────────────────
            subbed = ctypes.c_void_p()
            sub_raw = libIOReport.IOReportCreateSubscription(
                None, all_channels, ctypes.byref(subbed), 0, None
            )
            if not sub_raw:
                return
            subscribed_channels = subbed.value
            if not subscribed_channels:
                return

            # ── 3. Two samples (1 sec apart) ───────────────────────
            first = libIOReport.IOReportCreateSamples(sub_raw, subscribed_channels, None)
            if not first:
                return
            import time
            time.sleep(1.0)
            second = libIOReport.IOReportCreateSamples(sub_raw, subscribed_channels, None)
            if not second:
                return

            # ── 4. Delta ──────────────────────────────────────────
            delta = libIOReport.IOReportCreateSamplesDelta(first, second, None)
            if not delta:
                return

            # ── 5. Build name → cf_dict lookup from delta ─────────
            delta_arr_cf = get_dict_array_value(delta, "IOReportChannels")
            if not delta_arr_cf:
                return
            delta_lookup = {}
            try:
                d_n = cf.CFArrayGetCount(delta_arr_cf)
                for i in range(d_n):
                    try:
                        ch_cf = cf.CFArrayGetValueAtIndex(delta_arr_cf, i)
                        ch = cf_to_python(ch_cf)
                        if not ch:
                            continue
                        legend = ch.get("LegendChannel", [])
                        if len(legend) >= 3:
                            name = (legend[2] or "").strip()
                            delta_lookup[name] = ch_cf
                    except Exception:
                        continue
            except Exception:
                return

            # ── 6. Sum idle vs active per cluster ─────────────────
            INT64_MIN = -9223372036854775808
            e_active = e_idle = 0
            p_active = p_idle = 0

            for name, _ in cpu_refs:
                try:
                    val_cf = delta_lookup.get(name)
                    if not val_cf:
                        continue
                    val = libIOReport.IOReportSimpleGetIntegerValue(val_cf, 0)
                    if val == INT64_MIN:
                        continue  # "no data" sentinel — skip
                    if name.startswith("ECPM"):
                        if "idle" in name.lower():
                            e_idle += val
                        else:
                            e_active += val
                    elif name.startswith("PCPM"):
                        if "idle" in name.lower():
                            p_idle += val
                        else:
                            p_active += val
                except Exception:
                    continue  # one channel bad → skip it, keep going

            # ── 7. Emit (each cluster independent) ────────────────
            e_total = e_active + e_idle
            p_total = p_active + p_idle

            if e_total > 0:
                pct = e_idle / e_total * 100
                p("ecpu idle", f"{pct:.1f}%", "1;33")

            if p_total > 0:
                pct = p_idle / p_total * 100
                p("pcpu idle", f"{pct:.1f}%", "1;33")
        finally:
            try:
                cf.CFRelease(all_channels)
            except Exception:
                pass
    except Exception:
        # Absolute outermost catch — never propagate
        return


main()