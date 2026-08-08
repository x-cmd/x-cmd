# shellcheck shell=awk
# Detect storage shape and emit the password payload in a form the
# shell can hand straight to a downstream filter (`xxd -r -p` for
# binary blobs, `cat` for printable strings).
#
# Emits two lines:
#   <type>\n
#   <payload>
# The first line uses `printf` (no trailing newline) — wait, read needs
# a newline to delimit. So:
#   <type>\n         -- terminated; read consumes "type\n"
#   <payload>        -- NO trailing newline; downstream filter (xxd /
#                      cat) gets raw bytes only, no spurious \n
#
# Used by lib/impl/darwin ___x_cmd_keyring___keychain_get.

/^password:[[:space:]]0x/ {
    rest = substr($0, 11)
    sub(/ .*/, "", rest)
    printf "binary\n"
    printf "%s", rest
    exit
}

/^password:[[:space:]]"/ {
    printf "string\n"
    payload = substr($0, 11)
    sub(/^"/, "", payload)
    sub(/"$/, "", payload)
    printf "%s", payload
    exit
}