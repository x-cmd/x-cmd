# QR Code Encoder - Pure AWK Implementation
# Uses precompiled GF(256) tables for multiplication and bitwise ops
@include "precompile.awk"

BEGIN {
    # QR Version 1-15 capacity tables (Byte mode, EC Level L)
    # version -> max_chars
    CAPACITY[1] = 17
    CAPACITY[2] = 32
    CAPACITY[3] = 53
    CAPACITY[4] = 78
    CAPACITY[5] = 106
    CAPACITY[6] = 134
    CAPACITY[7] = 154
    CAPACITY[8] = 192
    CAPACITY[9] = 230
    CAPACITY[10] = 271
    CAPACITY[11] = 321
    CAPACITY[12] = 367
    CAPACITY[13] = 425
    CAPACITY[14] = 458
    CAPACITY[15] = 520

    # EC codewords per block for L level
    EC_L[1] = 7;  EC_TOTAL_L[1] = 19
    EC_L[2] = 10; EC_TOTAL_L[2] = 34
    EC_L[3] = 15; EC_TOTAL_L[3] = 55
    EC_L[4] = 20; EC_TOTAL_L[4] = 80
    EC_L[5] = 26; EC_TOTAL_L[5] = 108
    EC_L[6] = 18; EC_TOTAL_L[6] = 68
    EC_L[7] = 20; EC_TOTAL_L[7] = 78
    EC_L[8] = 24; EC_TOTAL_L[8] = 97
    EC_L[9] = 30; EC_TOTAL_L[9] = 116
    EC_L[10] = 18; EC_TOTAL_L[10] = 68
    EC_L[11] = 20; EC_TOTAL_L[11] = 81
    EC_L[12] = 24; EC_TOTAL_L[12] = 96
    EC_L[13] = 30; EC_TOTAL_L[13] = 108
    EC_L[14] = 28; EC_TOTAL_L[14] = 104
    EC_L[15] = 28; EC_TOTAL_L[15] = 112

    # Matrix size for each version
    MATRIX_SIZE[1] = 21
    MATRIX_SIZE[2] = 25
    MATRIX_SIZE[3] = 29
    MATRIX_SIZE[4] = 33
    MATRIX_SIZE[5] = 37
    MATRIX_SIZE[6] = 41
    MATRIX_SIZE[7] = 45
    MATRIX_SIZE[8] = 49
    MATRIX_SIZE[9] = 53
    MATRIX_SIZE[10] = 57
    MATRIX_SIZE[11] = 61
    MATRIX_SIZE[12] = 65
    MATRIX_SIZE[13] = 69
    MATRIX_SIZE[14] = 73
    MATRIX_SIZE[15] = 77

    # Data codewords (data capacity in codewords) for each version at EC Level L
    # Total codewords = DATA_CODEWORDS[version] + EC_L[version]
    DATA_CODEWORDS[1] = 13
    DATA_CODEWORDS[2] = 16
    DATA_CODEWORDS[3] = 24
    DATA_CODEWORDS[4] = 32
    DATA_CODEWORDS[5] = 44
    DATA_CODEWORDS[6] = 30
    DATA_CODEWORDS[7] = 28
    DATA_CODEWORDS[8] = 32
    DATA_CODEWORDS[9] = 40
    DATA_CODEWORDS[10] = 26
    DATA_CODEWORDS[11] = 32
    DATA_CODEWORDS[12] = 36
    DATA_CODEWORDS[13] = 44
    DATA_CODEWORDS[14] = 40
    DATA_CODEWORDS[15] = 44

    # Format info strings for mask patterns 0-7, EC level L
    # Extracted from qrcode library (verified correct for scannable QR)
    FORMAT_L[0] = "111011111000100"
    FORMAT_L[1] = "111001011110011"
    FORMAT_L[2] = "111110110101010"
    FORMAT_L[3] = "111100010011101"
    FORMAT_L[4] = "110011000101111"
    FORMAT_L[5] = "110001100011000"
    FORMAT_L[6] = "110110001000001"
    FORMAT_L[7] = "110100101110110"
}

# Byte XOR using gawk's xor() function
function gf_xor(a, b) {
    return xor(a, b)
}

# GF(256) multiplication using log/exp tables (still needed)
function gf_mul(a, b,    la, lb, t) {
    if (a == 0 || b == 0) return 0
    la = log_tbl[a]
    lb = log_tbl[b]
    t = (la + lb) % 255
    return exp_tbl[t]
}

# Get bit at position (0=MSB, 7=LSB) from byte using gawk bitwise
function get_bit(byte, pos) {
    return and(rshift(byte, 7-pos), 1)
}

# Determine version needed for data length
function get_version(len,    v) {
    for (v = 1; v <= 15; v++) {
        if (CAPACITY[v] >= len) return v
    }
    return 15  # max supported
}

# Get matrix size for version
function get_size(version) {
    return MATRIX_SIZE[version]
}

# Get EC codewords for version
function get_ec_codewords(version) {
    return EC_L[version]
}

# Get char count bits for byte mode
function get_char_count_bits(version) {
    if (version <= 9) return 8
    if (version <= 26) return 16
    return 16
}

# Encode data to bit string
function encode_data(data, version,    bits, i, c, len) {
    bits = ""

    # Mode indicator: 0100 for byte mode
    bits = bits "0100"

    # Character count indicator
    len = length(data)
    cc_bits = get_char_count_bits(version)
    for (i = cc_bits - 1; i >= 0; i--) {
        bits = bits ((len >= pw2(i)) ? "1" : "0")
        if (len >= pw2(i)) len -= pw2(i)
    }

    # Data bytes
    for (i = 1; i <= length(data); i++) {
        c = ord(substr(data, i, 1))
        for (bit = 7; bit >= 0; bit--) {
            bits = bits ((c >= pw2(bit)) ? "1" : "0")
            if (c >= pw2(bit)) c -= pw2(bit)
        }
    }

    return bits
}

# Pad bits to fill data capacity
function pad_bits(bits, version,    padded, rem, pad_byte) {
    padded = bits
    max_bits = DATA_CODEWORDS[version] * 8

    # Add terminator (max 4 bits)
    rem = max_bits - length(padded)
    if (rem >= 4) padded = padded "0000"

    # Pad with alternating bytes
    pad_byte = 0xEC  # 11101100
    rem = max_bits - length(padded)
    while (rem >= 8) {
        for (bit = 7; bit >= 0; bit--) {
            padded = padded ((pad_byte >= pw2(bit)) ? "1" : "0")
            if (pad_byte >= pw2(bit)) pad_byte -= pw2(bit)
        }
        pad_byte = (pad_byte == 0xEC) ? 0x11 : 0xEC  # alternate
        rem = max_bits - length(padded)
    }

    return padded
}

# Convert bit string to byte array
function bits_to_bytes(bits, bytes,    i, j, byte, n) {
    n = length(bits) / 8
    for (i = 0; i < n; i++) {
        byte = 0
        for (j = 0; j < 8; j++) {
            if (substr(bits, i*8 + j + 1, 1) == "1")
                byte += pw2(7 - j)
        }
        bytes[i] = byte
    }
    return n
}

# 2^n using multiplication
function pw2(n,    i, r) {
    r = 1
    for (i = 0; i < n; i++) r *= 2
    return r
}

# Ordinal value of character - get ASCII byte value
function ord(c,    s) {
    s = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\x5b]^\x60abcdefghijklmnopqrstuvwxyz{|}~"
    return index(s, c) > 0 ? index(s, c) + 31 : 0
}

# Reed-Solomon encode
function rs_encode(data_bytes, data_len, ec_len, result,    gen, i, j, coef) {
    # Initialize result with data + zeros
    for (i = 0; i < data_len; i++) result[i] = data_bytes[i]
    for (i = data_len; i < data_len + ec_len; i++) result[i] = 0

    # Generator polynomial: precomputed for each ec_len
    init_gen_poly(gen, ec_len)

    # Division
    for (i = 0; i < data_len; i++) {
        coef = result[i]
        if (coef != 0) {
            for (j = 0; j < ec_len; j++) {
                if (gen[j] != 0) {
                    result[i + j + 1] = gf_xor(result[i + j + 1], gf_mul(coef, gen[j]))
                }
            }
        }
    }

    # EC codewords are now in result[data_len ... data_len+ec_len-1]
    return data_len + ec_len
}

# Initialize generator polynomial for given ec_len
function init_gen_poly(gen, ec_len,    i) {
    # Precomputed generator polynomials (from qrencode source)
    # gen[0..ec_len] coefficients

    # For ec_len = 7 (V1):
    if (ec_len == 7) {
        gen[0] = 0;  gen[1] = 87;  gen[2] = 229; gen[3] = 146; gen[4] = 77;  gen[5] = 224; gen[6] = 248; gen[7] = 120
        return
    }
    # For ec_len = 10 (V2):
    if (ec_len == 10) {
        gen[0] = 0;  gen[1] = 251; gen[2] = 162; gen[3] = 52;  gen[4] = 99;  gen[5] = 112; gen[6] = 220; gen[7] = 224; gen[8] = 200; gen[9] = 104; gen[10] = 144; gen[11] = 190
        return
    }
    # For ec_len = 15 (V3):
    if (ec_len == 15) {
        gen[0] = 0;   gen[1] = 8;   gen[2] = 183; gen[3] = 61;  gen[4] = 91;  gen[5] = 202; gen[6] = 37;  gen[7] = 51;  gen[8] = 35;  gen[9] = 11;  gen[10] = 106; gen[11] = 117; gen[12] = 138; gen[13] = 45;  gen[14] = 50;  gen[15] = 192
        return
    }
    # For ec_len = 20 (V4):
    if (ec_len == 20) {
        gen[0] = 0;  gen[1] = 17;  gen[2] = 60;  gen[3] = 79;  gen[4] = 50;  gen[5] = 61;  gen[6] = 220; gen[7] = 236; gen[8] = 69;  gen[9] = 70;  gen[10] = 97;  gen[11] = 64;  gen[12] = 59;  gen[13] = 43;  gen[14] = 206; gen[15] = 1;   gen[16] = 220; gen[17] = 211; gen[18] = 117; gen[19] = 240; gen[20] = 242
        return
    }
    # Fallback: compute dynamically
    gen[0] = 1
    for (i = 1; i <= ec_len; i++) gen[i] = 0

    # Multiply by (x - a^i) for i = 0 to ec_len-1
    for (i = 0; i < ec_len; i++) {
        for (j = ec_len; j > 0; j--) {
            gen[j] = gf_mul(gen[j], exp_tbl[i+1])
            gen[j] = gf_xor(gen[j], gen[j-1])
        }
        gen[0] = gf_mul(gen[0], exp_tbl[i+1])
    }
}

# Build QR matrix
function build_matrix(result, total_len, version,    matrix, size, i, j, bit_idx, mask) {
    size = MATRIX_SIZE[version]
    mask = 0  # Use mask 0 for simplicity

    # Initialize
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            matrix[i, j] = 0
        }
    }

    # Finder patterns
    add_finder(matrix, 0, 0, size)
    add_finder(matrix, size - 7, 0, size)
    add_finder(matrix, 0, size - 7, size)

    # Separators
    add_separators(matrix, size)

    # Timing patterns
    add_timing(matrix, size)

    # Alignment patterns (version 2+)
    if (version >= 2) {
        add_alignment(matrix, version, size)
    }

    # Place data bits (mask applied inline during placement)
    place_data(matrix, size, result, total_len, mask)

    # Note: apply_mask() is NOT called here because place_data()
    # already applies the mask to each bit as it's placed.

    # Format info
    add_format(matrix, size, FORMAT_L[mask], version)

    # Version info (version 7+)
    if (version >= 7) {
        add_version(matrix, size, version)
    }

    return size
}

function add_finder(matrix, row, col, size,    i, j) {
    for (i = 0; i < 7; i++) {
        matrix[row, col + i] = 1
        matrix[row + 6, col + i] = 1
        matrix[row + i, col] = 1
        matrix[row + i, col + 6] = 1
    }
    for (i = 1; i < 6; i++) {
        for (j = 1; j < 6; j++) {
            matrix[row + i, col + j] = 0
        }
    }
    for (i = 2; i < 5; i++) {
        for (j = 2; j < 5; j++) {
            matrix[row + i, col + j] = 1
        }
    }
}

function add_separators(matrix, size,    i) {
    for (i = 0; i < 8; i++) {
        matrix[7, i] = 0
        matrix[size - 8, i] = 0
        matrix[i, 7] = 0
        matrix[i, size - 8] = 0
    }
}

function add_timing(matrix, size,    i) {
    for (i = 8; i < size - 8; i++) {
        matrix[6, i] = (i % 2 == 0) ? 1 : 0
        matrix[i, 6] = (i % 2 == 0) ? 1 : 0
    }
}

function add_alignment(matrix, version, size,    pos, i, j, center, n, step) {
    # Alignment pattern centers for each version
    if (version == 2) { pos[0] = 6; pos[1] = size - 7 }
    else if (version == 3) { pos[0] = 6; pos[1] = 16; pos[2] = size - 7 }
    else if (version == 4) { pos[0] = 6; pos[1] = 18; pos[2] = size - 7 }
    else if (version == 5) { pos[0] = 6; pos[1] = 22; pos[2] = size - 7 }
    else if (version == 6) { pos[0] = 6; pos[1] = 24; pos[2] = size - 7 }
    else {
        # Generic: 3 patterns at regular intervals
        n = int(version / 7) + 2
        step = int((size - 13) / (n - 1))
        for (i = 0; i < n; i++) {
            pos[i] = 6 + i * step
        }
        pos[n-1] = size - 7
    }

    # Draw alignment patterns
    for (i = 0; pos[i] != ""; i++) {
        center = pos[i]
        if (center + 2 < size) {
            for (j = -2; j <= 2; j++) {
                matrix[center + j, center - 2] = 1
                matrix[center + j, center + 2] = 1
                matrix[center - 2, center + j] = 1
                matrix[center + 2, center + j] = 1
            }
            for (j = -1; j <= 1; j++) {
                for (k = -1; k <= 1; k++) {
                    if (j != 0 || k != 0) matrix[center + j, center + k] = 0
                }
            }
            matrix[center, center] = 1
        }
    }
}

function is_reserved(row, col, size) {
    # Finder patterns (7x7 at corners)
    if (row < 8 && col < 8) return 1         # top-left finder area
    if (row < 8 && col > size - 8) return 1    # top-right finder area
    if (row > size - 8 && col < 8) return 1   # bottom-left finder area
    # Timing patterns (row 6 and column 6)
    if (row == 6 || col == 6) return 1
    # Separator - only around finder patterns, not entire row/col 7
    # Row 7, cols 0-8 (left side separator)
    if (row == 7 && col < 8) return 1
    # Row 7, cols size-8 to size-1 (right side separator)
    if (row == 7 && col > size - 8) return 1
    # Col 7, rows 0-8 (top separator)
    if (col == 7 && row < 8) return 1
    # Col 7, rows size-8 to size-1 (bottom separator)
    if (col == 7 && row > size - 8) return 1
    return 0
}

function place_data(matrix, size, data, data_len, mask,    bit_idx, i, j, k, col, row, byte_idx, bit, byte_val) {
    bit_idx = 0
    for (j = size - 1; j >= 1; j -= 2) {
        if (j == 6) j = 5
        for (i = 0; i < size; i++) {
            for (k = 0; k < 2; k++) {
                col = j - k
                row = (j % 2 == 0) ? size - 1 - i : i
                if (is_reserved(row, col, size)) continue
                byte_idx = int(bit_idx / 8)
                bit = 7 - (bit_idx % 8)
                byte_val = data[byte_idx]
                byte_val = get_bit(byte_val, bit)
                if (get_mask_bit(row, col, mask))
                    byte_val = 1 - byte_val
                matrix[row, col] = byte_val
                bit_idx++
            }
        }
    }
}

function get_mask_bit(row, col, mask) {
    if (mask == 0) return (row + col) % 2 == 0 ? 1 : 0
    if (mask == 1) return row % 2 == 0 ? 1 : 0
    if (mask == 2) return col % 3 == 0 ? 1 : 0
    if (mask == 3) return (row + col) % 3 == 0 ? 1 : 0
    if (mask == 4) return (int(row / 2) + int(col / 3)) % 2 == 0 ? 1 : 0
    if (mask == 5) return ((row * col) % 2 + (row * col) % 3) % 2 == 0 ? 1 : 0
    if (mask == 6) return (((row * col) % 2 + (row * col) % 3) % 2 == 0) ? 1 : 0
    if (mask == 7) return (((row + col) % 2 + (row * col) % 3) % 2 == 0) ? 1 : 0
    return 0
}

function apply_mask(matrix, size, mask,    i, j) {
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            if (!is_reserved(i, j, size)) {
                if (get_mask_bit(i, j, mask))
                    matrix[i, j] = 1 - matrix[i, j]
            }
        }
    }
}

function add_format(matrix, size, format_bits, version,    i) {
    # Around top-left finder
    for (i = 0; i < 6; i++) {
        matrix[8, i] = substr(format_bits, i+1, 1) + 0
    }
    matrix[8, 7] = substr(format_bits, 7, 1) + 0
    matrix[8, 8] = substr(format_bits, 8, 1) + 0
    matrix[7, 8] = substr(format_bits, 9, 1) + 0

    # Left of top-left finder (vertical, bits 9-14)
    for (i = 0; i < 6; i++) {
        matrix[5 - i, 8] = substr(format_bits, 9 + i, 1) + 0
    }

    # Below bottom-left finder
    for (i = 0; i < 8; i++) {
        matrix[size - 1 - i, 8] = substr(format_bits, 15 - i, 1) + 0
    }

    # Right of top-right finder
    for (i = 0; i < 8; i++) {
        matrix[8, size - 8 + i] = substr(format_bits, i+1, 1) + 0
    }
}

function add_version(matrix, size, version,    i) {
    # Version info is placed in 3 positions around finder patterns
    # For version 7+
    if (version >= 7) {
        # This is a simplified version - full implementation would need more complex placement
    }
}

# Render QR code to terminal using half blocks to pack 2 rows per visual line
function render(matrix, size,    i, j, line, top, bot, indent) {
    indent = "  "  # 2 spaces left margin
    # Top margin
    print ""
    print indent
    for (i = 0; i < size; i += 2) {
        line = indent
        for (j = 0; j < size; j++) {
            top = (i < size) ? matrix[i, j] : 0
            bot = (i + 1 < size) ? matrix[i+1, j] : 0
            if (top && bot) {
                line = line "█"
            } else if (top && !bot) {
                line = line "▀"
            } else if (!top && bot) {
                line = line "▄"
            } else {
                line = line " "
            }
        }
        print line
    }
    # Bottom margin
    print indent
    print ""
}

# Main encoding function
function qr_encode(data,    version, bits, padded, n_bytes, bytes, ec_len, result, total_len, size, matrix) {
    version = get_version(length(data))
    ec_len = get_ec_codewords(version)

    bits = encode_data(data, version)
    padded = pad_bits(bits, version)
    n_bytes = bits_to_bytes(padded, bytes)

    total_len = rs_encode(bytes, n_bytes, ec_len, result)

    size = build_matrix(result, total_len, version, matrix)
    render(matrix, size)
}

# Main entry point when run via awk
BEGIN {
    if (DATA != "") {
        qr_encode(DATA)
        exit
    }
}
