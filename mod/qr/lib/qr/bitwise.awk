# Precomputed bitwise operations for POSIX awk
# Uses nibble decomposition: byte XOR = (high XOR high)<<4 | (low XOR low)
# Total size: ~23KB for all tables

@include "tables.txt"

BEGIN {
    # Tables are loaded via @include
}

# Byte XOR using precomputed nibble tables
function gf_xor(a, b) {
    ha = high_nibble[a]
    hb = high_nibble[b]
    la = low_nibble[a]
    lb = low_nibble[b]
    return nibble_xor[ha*16 + hb] * 16 + nibble_xor[la*16 + lb]
}

# Byte AND
function gf_and(a, b) {
    ha = high_nibble[a]
    hb = high_nibble[b]
    la = low_nibble[a]
    lb = low_nibble[b]
    return nibble_and[ha*16 + hb] * 16 + nibble_and[la*16 + lb]
}

# Byte OR
function gf_or(a, b) {
    ha = high_nibble[a]
    hb = high_nibble[b]
    la = low_nibble[a]
    lb = low_nibble[b]
    return nibble_or[ha*16 + hb] * 16 + nibble_or[la*16 + lb]
}

# Get bit at position (0=MSB, 7=LSB) from byte
# Uses nibble_bits which is also in tables.txt
function get_bit(byte, pos) {
    if (pos < 4)
        return nibble_bits[high_nibble[byte] * 4 + pos]
    else
        return nibble_bits[low_nibble[byte] * 4 + (pos-4)]
}
