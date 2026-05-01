#!/usr/bin/env gawk
# Generator script for precomputed bitwise tables
# Run once to generate bitwise tables for POSIX awk

BEGIN {
    # Generate bit extraction table
    # bit_cache[byte*8 + bit_position] = 0 or 1
    # where bit_position 0 = MSB, 7 = LSB

    print "# Precomputed bit extraction: bit_cache[byte*8 + pos] (pos 0=MSB, 7=LSB)"
    for (byte = 0; byte < 256; byte++) {
        for (pos = 0; pos < 8; pos++) {
            # bit at position pos (0=MSB) = (byte >> (7-pos)) & 1
            v = and(rshift(byte, 7-pos), 1)
            printf "bit_cache[%d]=%d ", byte*8+pos, v
        }
        if (byte % 32 == 31) print ""
    }
    print ""

    # Generate XOR table
    print "# Precomputed XOR: xor_cache[a*256+b]"
    for (a = 0; a < 256; a++) {
        for (b = 0; b < 256; b++) {
            printf "xor_cache[%d]=%d ", a*256+b, xor(a, b)
        }
        if (a % 4 == 3) print ""
    }
    print ""

    # Generate AND table
    print "# Precomputed AND: and_cache[a*256+b]"
    for (a = 0; a < 256; a++) {
        for (b = 0; b < 256; b++) {
            printf "and_cache[%d]=%d ", a*256+b, and(a, b)
        }
        if (a % 4 == 3) print ""
    }
    print ""

    # Generate OR table
    print "# Precomputed OR: or_cache[a*256+b]"
    for (a = 0; a < 256; a++) {
        for (b = 0; b < 256; b++) {
            printf "or_cache[%d]=%d ", a*256+b, or(a, b)
        }
        if (a % 4 == 3) print ""
    }
}
