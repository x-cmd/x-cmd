function getval(s) { i = index(s, ": "); return i > 0 ? substr(s, i + 2) : "" }
function C(c, s) { return tty ? "\033[" c "m" s "\033[0m" : s }
function pc(label, val,    color) {
    if (label ~ /^processor|^physical|^packages|^model name|^vendor|^cpu family|^model$|^stepping/) color = "1;36"
    else if (label ~ /cache|^L[123] |cache line/) color = "1;33"
    else if (label ~ /frequency|^bus freq/) color = "1;35"
    else if (label ~ /^page size|^memory$/) color = "1;32"
    else if (label ~ /cores$|cores:/) color = "1;34"
    else if (label ~ /^flags|^ext flags|^arm features/) color = "37"
    else color = "0"
    if (tty) printf "\033[%sm%-25s\033[0m: %s\n", color, label, val
    else printf "%-25s: %s\n", label, val
}
function fmtbytes(b,    u) {
    u = b >= 1073741824 ? "GB" : (b >= 1048576 ? "MB" : "KB")
    return sprintf("%.0f " u, b / (u == "GB" ? 1073741824 : (u == "MB" ? 1048576 : 1024)))
}
function fmthz(h) {
    if (h >= 1000000000) return sprintf("%.2f GHz", h / 1000000000)
    if (h >= 1000000) return sprintf("%.0f MHz", h / 1000000)
    return h " Hz"
}
/^hw\.(logicalcpu|ncpu):/                   { if (nproc == 0) nproc = getval($0) + 0 }
/^hw\.physicalcpu:/                         { phycores = getval($0) + 0 }
/^hw\.memsize:/                             { memsize = getval($0) + 0 }
/^hw\.cpufrequency_max:/                    { freqmax = getval($0) + 0 }
/^hw\.cpufrequency_min:/                    { freqmin = getval($0) + 0 }
/^hw\.packages:/                            { packages = getval($0) + 0 }
/^hw\.busfrequency:/                         { busfreq = getval($0) + 0 }
/^hw\.pagesize:/                             { pagesize = getval($0) + 0 }
/^hw\.cachelinesize:/                        { cacheline = getval($0) + 0 }
/^hw\.l1icachesize:/                         { l1i = getval($0) + 0 }
/^hw\.l1dcachesize:/                         { l1d = getval($0) + 0 }
/^hw\.l2cachesize:/                          { l2total = getval($0) + 0 }
/^hw\.l3cachesize:/                          { l3 = getval($0) + 0 }
/^hw\.perflevel0\.name:/                    { p0name = getval($0) }
/^hw\.perflevel0\.physicalcpu:/             { p0cpu = getval($0) + 0 }
/^hw\.perflevel0\.l2cachesize:/             { p0l2 = getval($0) + 0 }
/^hw\.perflevel1\.name:/                    { p1name = getval($0) }
/^hw\.perflevel1\.physicalcpu:/             { p1cpu = getval($0) + 0 }
/^hw\.perflevel1\.l2cachesize:/             { p1l2 = getval($0) + 0 }
/^machdep\.cpu\.brand_string:/              { brand = getval($0) }
/^machdep\.cpu\.vendor:/                    { vendor = getval($0) }
/^machdep\.cpu\.family:/                    { family = getval($0) }
/^machdep\.cpu\.model:/                     { cmodel = getval($0) }
/^machdep\.cpu\.stepping:/                  { stepping = getval($0) }
/^machdep\.cpu\.core_count:/                { cores = getval($0) }
/^machdep\.cpu\.cache\.size:/               { cache = getval($0) }
/^machdep\.cpu\.features:/                  { flags = getval($0) }
/^machdep\.cpu\.extfeatures:/               { extflags = getval($0) }
/^hw\.optional\.arm\./ {
    split($0, a, ": ")
    if (a[2] == "1") {
        name = a[1]
        gsub(/^hw\.optional\.arm\./, "", name)
        narm++
        armfeat[narm] = name
    }
}
END {
    if (nproc == 0) exit 1
    # Identity
    pc("processor count", nproc)
    if (phycores) pc("physical cores", phycores)
    if (!simple && packages) pc("packages", packages)
    if (brand)    pc("model name", brand)
    if (vendor)   pc("vendor_id", vendor)
    if (family)   pc("cpu family", family)
    if (cmodel)   pc("model", cmodel)
    if (stepping) pc("stepping", stepping)
    # Cache
    if (cores)    pc("cpu cores", cores)
    if (cache)    pc("cache size", cache " KB")
    if (!simple) {
        if (cacheline) pc("cache line size", cacheline " B")
        if (l1i)      pc("L1 instruction cache", fmtbytes(l1i))
        if (l1d)      pc("L1 data cache", fmtbytes(l1d))
        if (l2total)  pc("L2 cache", fmtbytes(l2total))
        if (l3)       pc("L3 cache", fmtbytes(l3))
    }
    # Frequency
    if (freqmax)  pc("cpu max frequency", fmthz(freqmax))
    if (freqmin)  pc("cpu min frequency", fmthz(freqmin))
    if (!simple && busfreq) pc("bus frequency", fmthz(busfreq))
    # Memory
    if (!simple && pagesize) pc("page size", pagesize / 1024 " KB")
    if (memsize)  pc("memory", fmtbytes(memsize))
    # Architecture (P/E cores)
    if (p0cpu)    pc("performance cores", p0cpu " (" p0name ")")
    if (!simple && p0l2) pc("performance L2 cache", fmtbytes(p0l2))
    if (p1cpu)    pc("efficiency cores", p1cpu " (" p1name ")")
    if (!simple && p1l2) pc("efficiency L2 cache", fmtbytes(p1l2))
    # Features
    if (flags)    pc("flags", flags)
    if (extflags) pc("ext flags", extflags)
    if (!simple && narm > 0) {
        s = armfeat[1]
        for (i = 2; i <= narm; i++) s = s ", " armfeat[i]
        pc("arm features", s)
    }
}
