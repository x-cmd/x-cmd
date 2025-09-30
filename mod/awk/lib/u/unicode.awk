
# unicode_to_utf8("\\u5f53")

function str_unicode2utf8(src,          ans){
    while (match(src, RE_UNICODE)) {
        ans = ans substr(src, 1, RSTART-1) unicode_to_utf8( substr(src, RSTART, RLENGTH) )
        src = substr(src, RSTART+RLENGTH)
    }
    return ans src
}

function unicode_to_utf8(unicode,               utf8, dec) {
    gsub(/^\\u/, "", unicode)
    dec = hex_to_dec("0x" unicode)

    if (dec < 0x80) {
        utf8 = sprintf("%c", dec)
    } else if (dec < 0x800) {
        utf8 = sprintf("%c%c", 0xC0 + int(dec / 64), 0x80 + (dec % 64))
    } else if (dec < 0x10000) {
        utf8 = sprintf("%c%c%c", 0xE0 + int(dec / 4096), 0x80 + int((dec / 64) % 64), 0x80 + (dec % 64))
    } else if (dec < 0x200000) {
        utf8 = sprintf("%c%c%c%c", 0xF0 + int(dec / 262144), 0x80 + int((dec / 4096) % 64), 0x80 + int((dec / 64) % 64), 0x80 + (dec % 64))
    }

    return utf8
}

function unicode_to_utf16(){

}

# Using byte to byte conversion
function utf8_to_utf16(){

}

# Using regex and byte to byte conversion
# TODO: This is important for the json string decode
function utf16_to_utf8(){

}
