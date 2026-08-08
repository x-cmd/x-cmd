# shellcheck shell=awk
# Parse `security dump-keychain` output and emit
#   service<TAB>namespace
# one per generic-password (genp) entry, filtered by svc_f / acct_f
# (passed as awk -v).
#
# Used by lib/impl/darwin ___x_cmd_keyring___keychain_ls (local keychain
# ls) AND lib/icloud ___x_cmd_keyring_cls (iCloud ls) — both feed the
# SAME `security dump-keychain` stream (no -k on iCloud; default search
# list includes iCloud when enabled), so the parser is identical.

/^class:[[:space:]]/ {
    s = $0
    sub(/^class:[[:space:]]*"/, "", s)
    sub(/"[^"]*$/, "", s)
    cur_cls = s
    cur_svce = ""
    cur_acct = ""
    next
}

/^keychain:[[:space:]]/ {
    if (cur_cls == "genp" && cur_svce != "" && (svc_f == "" || cur_svce == svc_f) && (acct_f == "" || cur_acct == acct_f))
        print cur_svce "\t" cur_acct
    cur_cls = ""; cur_svce = ""; cur_acct = ""
    next
}

cur_cls == "genp" {
    n = split($0, parts, "\"")
    if (n >= 5) {
        if (parts[2] == "svce") cur_svce = parts[4]
        else if (parts[2] == "acct") cur_acct = parts[4]
    }
}

END {
    if (cur_cls == "genp" && cur_svce != "" && (svc_f == "" || cur_svce == svc_f) && (acct_f == "" || cur_acct == acct_f))
        print cur_svce "\t" cur_acct
}