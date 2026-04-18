/^Class:/  { curclass = $0; sub(/^Class:\t/, "", curclass); in_gpu = (tolower(curclass) ~ /vga|display|3d/) }
in_gpu && /^Vendor:/ { gpuvendor = $0; sub(/^Vendor:\t/, "", gpuvendor) }
in_gpu && /^Device:/ { gpu = $0; sub(/^Device:\t/, "", gpu) }
in_gpu && /^Driver:/ { gpudriver = $0; sub(/^Driver:\t/, "", gpudriver) }
in_gpu && /^Rev:/    { gpurev = $0; sub(/^Rev:\t/, "", gpurev) }
/^$/ { in_gpu = 0 }
END {
    if (!gpu) exit 1
    printf "%-25s: %s\n", "gpu", gpu
    if (gpuvendor) printf "%-25s: %s\n", "vendor", gpuvendor
    if (gpudriver) printf "%-25s: %s\n", "driver", gpudriver
    if (gpurev)    printf "%-25s: %s\n", "revision", gpurev
}