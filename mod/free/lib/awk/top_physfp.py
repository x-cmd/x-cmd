# top_physfp.py - Fast phys_footprint collector for macOS via proc_pid_rusage
# Output: TSV of pid\tphysfp_kb for all accessible processes
# Used by: top.awk via getline when mem_col=="mem" on macOS
#
# Performance: ~50ms for 500+ processes (vs ~1.3s for footprint CLI)

import ctypes, ctypes.util, struct, subprocess, sys

def main():
    try:
        libproc = ctypes.CDLL(ctypes.util.find_library('libproc'))
    except Exception:
        sys.exit(1)

    buf_size = 128  # rusage_info_v4 is ~232 bytes, 128 uint64s = 1024 bytes
    out = []

    try:
        ps_out = subprocess.check_output(
            ['ps', 'ax', '-o', 'pid=,rss='], text=True, timeout=5)
    except Exception:
        sys.exit(1)

    for line in ps_out.split('\n'):
        parts = line.strip().split()
        if len(parts) < 2:
            continue
        try:
            pid = int(parts[0])
        except ValueError:
            continue

        buf = ctypes.create_string_buffer(buf_size * 8)
        ret = libproc.proc_pid_rusage(pid, 4, buf)
        if ret == 0:
            vals = struct.unpack_from('<' + 'Q' * buf_size, buf.raw)
            # ri_phys_footprint is at offset 72 = uint64 index 9
            phys_fp_kb = int(vals[9] / 1024)
            if phys_fp_kb > 0:
                out.append(f'{pid}\t{phys_fp_kb}')

    sys.stdout.write('\n'.join(out))
    if out:
        sys.stdout.write('\n')

if __name__ == '__main__':
    main()
