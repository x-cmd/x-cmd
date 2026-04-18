# Query CPU load on macOS.
# On Apple Silicon, host_statistics idle=0 (known bug), so we parse top.
# Falls back to host_processor_info for per-core data (also idle=0, computed).
# Outputs in the same "%-25s: %s" format.
# Usage: python3 <this_file> [tty]

import ctypes, ctypes.util, subprocess, sys, time, re

tty = len(sys.argv) > 1 and sys.argv[1] == "1"

def p(k, v, color="0"):
    if tty:
        print(f"\033[{color}m%-25s\033[0m: %s" % (k, v))
    else:
        print(f"%-25s: %s" % (k, v))

# ── Overall CPU load via top ─────────────────────────────────────
# top -l 2 samples twice; the 2nd line is the real-time measurement
try:
    r = subprocess.run(["top", "-l", "2", "-n", "0", "-s", "1"],
                        capture_output=True, text=True, timeout=10)
    cpu_lines = [l for l in r.stdout.split("\n") if l.startswith("CPU usage:")]
    if len(cpu_lines) >= 2:
        # Parse: "CPU usage: 7.55% user, 3.77% sys, 88.67% idle"
        m = re.match(r"CPU usage:\s+([\d.]+)%\s+user,\s+([\d.]+)%\s+sys,\s+([\d.]+)%\s+idle", cpu_lines[1])
        if m:
            p("cpu user",   f"{m.group(1)}%", "1;32")
            p("cpu system", f"{m.group(2)}%", "1;32")
            p("cpu idle",   f"{m.group(3)}%", "1;32")
except:
    pass

# ── Per-core usage via host_processor_info ────────────────────────
# On Apple Silicon idle=0, so we compute idle from delta total - (user+nice+sys_active)
# We sample twice and use deltas
lib = ctypes.CDLL(ctypes.util.find_library("c"))
CPU_STATE_MAX = 4
PROCESSOR_CPU_LOAD_INFO = 2

def get_per_core_ticks():
    num_cpu = ctypes.c_uint32()
    cpu_info = ctypes.POINTER(ctypes.c_int32)()
    num_cpu_info = ctypes.c_uint32()
    ret = lib.host_processor_info(
        lib.mach_host_self(), PROCESSOR_CPU_LOAD_INFO,
        ctypes.byref(num_cpu), ctypes.byref(cpu_info), ctypes.byref(num_cpu_info)
    )
    if ret != 0 or not cpu_info:
        return None, 0
    cores = []
    for core in range(num_cpu.value):
        base = core * CPU_STATE_MAX
        cores.append([cpu_info[base + i] for i in range(CPU_STATE_MAX)])
    lib.vm_deallocate(lib.mach_task_self(), cpu_info, num_cpu_info.value * 4)
    return cores, num_cpu.value

c1, ncores = get_per_core_ticks()
if c1:
    time.sleep(1)
    c2, _ = get_per_core_ticks()
    if c2:
        for core in range(ncores):
            d = [c2[core][i] - c1[core][i] for i in range(CPU_STATE_MAX)]
            t = sum(d)
            if t > 0:
                # On Apple Silicon: d[3](idle)=0, idle is in system(d[2])
                # user=d[0], nice=d[1], system_active = total - user - nice - idle
                # Since idle=0 in ticks, we treat system as the remainder
                user_pct = d[0] / t * 100
                nice_pct = d[1] / t * 100
                sys_pct  = d[2] / t * 100
                p(f"core {core:2d}",
                  f"user={user_pct:5.1f}% sys={sys_pct:5.1f}%",
                  "36")
