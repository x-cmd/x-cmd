
BEGIN{
    datadir = ENVIRON[ "datadir" ]

    getline
    while (1) {
        if ($0 ~ /^Active[ ]Internet/) {
            if ($0 ~ /including[ ]servers/) {
                handle_internet_macos()
            } else {
                handle_internet_linux()
            }
        } else if ($0 ~ /Active[ ]UNIX/) {
            handle_unix()
        } else if ($0 ~ /Active[ ]LOCAL/) {
            handle_local()
        } else if ($0 ~ /^Active[ ]Connections/) {
            handle_connection()
        } else if ($0 ~ /^Active[ ]kernel[ ]event/) {
            handle_kernel_event()
        } else if ($0 ~ /^Active[ ]kernel[ ]control/) {
            handle_kernel_control()
        } else {
            if (!getline) break
        }
    }
}

function repeat( time, word,        i, s ){
    s = ""
    for (i=1; i<=time; ++i) {
        s = s "%s\t"
    }

    return s
}

# linux
function handle_internet_linux(){
    title = $0
    getline
    header = $0
    gsub(/Local[ ]+Address/, "Local-Address", header)
    gsub(/Foreign[ ]+Address/, "Foreign-Address", header)

    $0 = header
    fields = $0

    fmt = repeat( 6, "%s\t" ) "%s\n"

    printf(fmt,     \
        "proto", "recvq", "sendq", "local", "foreign", "state", "program" \
    ) >>(datadir "/internet")

    while (getline) {
        if ( ($1 == "Active") || ($1 == "Registered") )     break

        proto = $1
        recvq = $2
        sendq = $3
        local = $4
        foreign = $5

        if (proto ~ /udp/) {
            state = ""
            base = 6
            program = ""
        } else {
            state = $6
            program = $7
        }

        printf(fmt, \
            proto, recvq, sendq, local, foreign, state, program \
        ) >>(datadir "/internet")
    }
}

# macos
function handle_internet_macos(){
    title = $0
    getline
    header = $0
    gsub(/Local[ ]+Address/, "Local-Address", header)
    gsub(/Foreign[ ]+Address/, "Foreign-Address", header)

    $0 = header
    fields = $0

    fmt = repeat( 11, "%s\t" ) "%s\n"

    printf(fmt,     \
        "proto", "recvq", "sendq", "local", "foreign", "state", "rhiwat", "shiwat", "pid", "epid", "state2", "option" \
    ) >>(datadir "/internet")

    while (getline) {
        if ( ($1 == "Active") || ($1 == "Registered") )     break

        proto = $1
        recvq = $2
        sendq = $3
        local = $4
        foreign = $5

        if (proto ~ /udp/) {
            state = ""
            base = 6
        } else {
            state = $6
            base = 7
        }

        rhiwat = $base
        shiwat = $(base+1)
        pid = $(base+2)
        epid = $(base+3)
        state2 = $(base+4)
        option = $(base+5)

        printf(fmt, \
            proto, recvq, sendq, local, foreign, state, rhiwat, shiwat, pid, epid, state2, option \
        ) >>(datadir "/internet")
    }
}

# linux
function handle_unix(){
    title = $0
    getline
    header = $0
    fmt = repeat( 7, "%s\t" ) "%s\n"

    printf(fmt,     "proto", "refcnt", "flags", "type", "state", "inode", "program", "path" )>>(datadir "/domain")

    while (getline) {
        if ( ($1 == "Active") || ($1 == "Registered") )     break

        proto   = $1
        refcnt  = $2
        flags   = $4
        if (flags == "]") {
            flags = ""
            base = 5
        } else {
            base = 6
        }
        type    = $base

        state   = $(base+1)
        if (state ~ /[0-9]+/) {
            state = ""
            inode = $(base)
            program = $(base+1)   # ""
            path = ""
        } else {
            inode   = $(base+2)
            program = $(base+3)
            path = substr($0, index( $0, program ) + length(program))
            gsub(/(^[ ]+)|([ ]+$)/, "", path)
        }

        printf( fmt, \
            proto, refcnt, flags, type, state, inode, program, path \
        ) >>(datadir "/domain")
    }
}

# macos
function handle_local(){
    title = $0
    getline
    header = $0

    fmt = repeat( 22, "%s\t" ) "%s\n"  # Adjusted repeat count for new header

    printf(fmt,     \
        "Address", "Type", "Recv-Q", "Send-Q", "Inode", "Conn", "Refs", "Nextref", "rxbytes", "txbytes", "rhiwat", "shiwat", "pid", "epid", "state", "options", "gencnt", "flags", "flags1", "usecnt", "rtncnt", "fltrs", "process" \
    )>>(datadir "/domain")

    while (getline) {
        if ( ($1 == "Active") || ($1 == "Registered") )     break
        addr    = $1
        type    = $2
        recvq   = $3
        sendq   = $4
        inode   = $5
        conn    = $6
        refs    = $7
        nextref = $8
        rxbytes = $9
        txbytes = $10
        rhiwat  = $11
        shiwat  = $12
        pid     = $13
        epid    = $14
        state   = $15
        options = $16
        gencnt  = $17
        flags   = $18
        flags1  = $19
        usecnt  = $20
        rtncnt  = $21
        fltrs   = $22
        process = $23

        printf( fmt, \
            addr, type, recvq, sendq, inode, conn, refs, nextref, rxbytes, txbytes, rhiwat, shiwat, pid, epid, state, options, gencnt, flags, flags1, usecnt, rtncnt, fltrs, process \
        ) >>(datadir "/domain")
    }
}

# Just windows
function handle_connection(){
    getline
    getline

    header = $0

    fmt = repeat( 4, "%s\t" ) "%s\n"

    printf(fmt,     "proto", "local", "foreign", "state", "pid" )>>(datadir "/internet")

    while (getline) {
        if ( ($1 == "Active") || ($1 == "Registered") )     break
        proto   = $1
        local   = $2
        foreign = $3
        state   = $4
        pid     = $5

        printf( fmt, proto, local, foreign, state, pid ) >>(datadir "/internet")
    }
}

function handle_kernel_event(){
    title = $0
    getline
    header = $0

    fmt = repeat( 19, "%s\t" ) "%s\n"

    printf(fmt, "Proto", "Recv-Q", "Send-Q", "vendor", "class", "subcl", "rxbytes", "txbytes", "rhiwat", "shiwat", "pid", "epid", "state", "options", "gencnt", "flags", "flags1", "usecnt", "rtncnt", "fltrs") >>(datadir "/kernel_event")

    while (getline) {
        if ( ($1 == "Active") || ($1 == "Registered") )     break
        proto   = $1
        recvq   = $2
        sendq   = $3
        vendor  = $4
        class   = $5
        subcl   = $6
        rxbytes = $7
        txbytes = $8
        rhiwat  = $9
        shiwat  = $10
        pid     = $11
        epid    = $12
        state   = $13
        options = $14
        gencnt  = $15
        flags   = $16
        flags1  = $17
        usecnt  = $18
        rtncnt  = $19
        fltrs   = $20

        printf( fmt, proto, recvq, sendq, vendor, class, subcl, rxbytes, txbytes, rhiwat, shiwat, pid, epid, state, options, gencnt, flags, flags1, usecnt, rtncnt, fltrs ) >>(datadir "/kernel_event")
    }
}

function handle_kernel_control(){
    title = $0
    getline
    header = $0

    fmt = repeat( 19, "%s\t" ) "%s\n"  # Adjusted repeat count for new header

    printf(fmt, "Proto", "Recv-Q", "Send-Q", "rxbytes", "txbytes", "rhiwat", "shiwat", "pid", "epid", "state", "options", "gencnt", "flags", "flags1", "usecnt", "rtncnt", "fltrs", "unit", "id", "name") >>(datadir "/kernel_control")

    while (getline) {
        if ( ($1 == "Active") || ($1 == "Registered") )     break
        proto   = $1
        recvq   = $2
        sendq   = $3
        rxbytes = $4  # Added rxbytes
        txbytes = $5  # Added txbytes
        rhiwat  = $6  # Shifted existing variables
        shiwat  = $7
        pid     = $8
        epid    = $9
        state   = $10
        options = $11
        gencnt  = $12
        flags   = $13
        flags1  = $14
        usecnt  = $15
        rtncnt  = $16
        fltrs   = $17
        unit    = $18
        id      = $19
        name    = $20

        printf( fmt,    \
            proto, recvq, sendq, rxbytes, txbytes, \
            rhiwat, shiwat, pid, epid, state, \
            options, gencnt, flags, flags1, usecnt, \
            rtncnt, fltrs, unit, id, name ) >>(datadir "/kernel_control")
    }
}

