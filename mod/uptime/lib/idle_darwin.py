import ctypes, ctypes.util

libc = ctypes.CDLL(ctypes.util.find_library("c"))
PROCESSOR_CPU_LOAD_INFO = 2
host = libc.mach_host_self()
num_cpu = ctypes.c_uint32(0)
cpu_info = ctypes.POINTER(ctypes.c_int)()
num_info = ctypes.c_uint32(0)
libc.host_processor_info.restype = ctypes.c_int
libc.host_processor_info.argtypes = [
    ctypes.c_uint, ctypes.c_uint,
    ctypes.POINTER(ctypes.c_uint32),
    ctypes.POINTER(ctypes.POINTER(ctypes.c_int)),
    ctypes.POINTER(ctypes.c_uint32),
]
libc.host_processor_info(host, PROCESSOR_CPU_LOAD_INFO,
    ctypes.pointer(num_cpu), ctypes.pointer(cpu_info), ctypes.pointer(num_info))
cols = [0, 0, 0, 0]
for i in range(num_cpu.value):
    for j in range(4):
        cols[j] += cpu_info[i*4+j]
print("%.2f" % (cols[2] / sum(cols) * 100))
