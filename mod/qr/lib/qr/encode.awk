# QR Code Encoder - Pure AWK Implementation
# Uses precompiled GF(256) tables for multiplication and bitwise ops

BEGIN {
    # GF(256) tables - exp_tbl[i] = 2^i in GF(256), log_tbl[a] = exponent i where exp_tbl[i] = a
    split("1 2 4 8 16 32 64 128 29 58 116 232 205 135 19 38 76 152 45 90 180 117 234 201 143 3 6 12 24 48 96 192 157 39 78 156 37 74 148 53 106 212 181 119 238 193 159 35 70 140 5 10 20 40 80 160 93 186 105 210 185 111 222 161 95 190 97 194 153 47 94 188 101 202 137 15 30 60 120 240 253 231 211 187 107 214 177 127 254 225 223 163 91 182 113 226 217 175 67 134 17 34 68 136 13 26 52 104 208 189 103 206 129 31 62 124 248 237 199 147 59 118 236 197 151 51 102 204 133 23 46 92 184 109 218 169 79 158 33 66 132 21 42 84 168 77 154 41 82 164 85 170 73 146 57 114 228 213 183 115 230 209 191 99 198 145 63 126 252 229 215 179 123 246 241 255 227 219 171 75 150 49 98 196 149 55 110 220 165 87 174 65 130 25 50 100 200 141 7 14 28 56 112 224 221 167 83 166 81 162 89 178 121 242 249 239 195 155 43 86 172 69 138 9 18 36 72 144 61 122 244 245 247 243 251 235 203 139 11 22 44 88 176 125 250 233 207 131 27 54 108 216 173 71 142 1", exp_tbl)
    split("0 1 25 2 50 26 198 3 223 51 238 27 104 199 75 4 100 224 14 52 141 239 129 28 193 105 248 200 8 76 113 5 138 101 47 225 36 15 33 53 147 142 218 240 18 130 69 29 181 194 125 106 39 249 185 201 154 9 120 77 228 114 166 6 191 139 98 102 221 48 253 226 152 37 179 16 145 34 136 54 208 148 206 143 150 219 189 241 210 19 92 131 56 70 64 30 66 182 163 195 72 126 110 107 58 40 84 250 133 186 61 202 94 155 159 10 21 121 43 78 212 229 172 115 243 167 87 7 112 192 247 140 128 99 13 103 74 222 237 49 197 254 24 227 165 153 119 38 184 180 124 17 68 146 217 35 32 137 46 55 63 209 91 149 188 207 205 144 135 151 178 220 252 190 97 242 86 211 171 20 42 93 158 132 60 57 83 71 109 65 162 31 45 67 216 183 123 164 118 196 23 73 236 127 12 111 246 108 161 59 82 41 157 85 170 251 96 134 177 187 204 62 90 203 89 95 176 156 169 160 81 11 245 22 235 122 117 44 215 79 174 213 233 230 231 173 232 116 214 244 234 168 80 88 175", log_tbl)
    # QR Version 1-15 capacity tables (Byte mode, EC Level L)
    # version -> data codewords (matching Python CAPACITY)
    CAPACITY[1] = 19
    CAPACITY[2] = 34
    CAPACITY[3] = 55
    CAPACITY[4] = 80
    CAPACITY[5] = 106
    CAPACITY[6] = 136
    CAPACITY[7] = 156
    CAPACITY[8] = 194
    CAPACITY[9] = 232
    CAPACITY[10] = 274
    CAPACITY[11] = 324
    CAPACITY[12] = 370
    CAPACITY[13] = 428
    CAPACITY[14] = 461
    CAPACITY[15] = 523

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
    # LSB-first format strings (matching Python implementation)
    FORMAT_L[0] = "001000111110111"
    FORMAT_L[1] = "110011110100111"
    FORMAT_L[2] = "010101011011111"
    FORMAT_L[3] = "101110010001111"
    FORMAT_L[4] = "111101000110011"
    FORMAT_L[5] = "000110001100011"
    FORMAT_L[6] = "100000100011011"
    FORMAT_L[7] = "011011101001011"
}

# Byte XOR using integer arithmetic (no bitwise operators needed)
function gf_xor(a, b,    i, r) {
    r = 0
    for (i = 0; i < 8; i++) {
        if ((int(a / 2^i) % 2) != (int(b / 2^i) % 2))
            r += 2^i
    }
    return r
}

# GF(256) multiplication using lookup tables
# AWK arrays are 1-indexed from split()
# log_tbl[a] = exponent i where exp_tbl[i+1] = a (AWK 1-indexed)
# exp_tbl[i] = 2^(i-1) in GF(256) (AWK 1-indexed, so exp_tbl[1] = 2^0 = 1)
function gf_mul(a, b,    t) {
    if (a == 0 || b == 0) return 0
    t = (log_tbl[a] + log_tbl[b]) % 255
    return exp_tbl[t + 1]
}

# Get bit at position (0=MSB, 7=LSB) from byte - works on gawk, mawk, nawk
function get_bit(byte, pos) {
    return (int(byte / (2^pos))) % 2
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
        p = pw2(i)
        bits = bits ((len >= p) ? "1" : "0")
        if (len >= p) len -= p
    }

    # Data bytes
    for (i = 1; i <= length(data); i++) {
        c = ord(substr(data, i, 1))
        for (bit = 7; bit >= 0; bit--) {
            p = pw2(bit)
            bits = bits ((c >= p) ? "1" : "0")
            if (c >= p) c -= p
        }
    }

    return bits
}

# Pad bits to fill data capacity
function pad_bits(bits, version,    padded, rem, pad_byte, pad_copy) {
    padded = bits
    max_bits = CAPACITY[version] * 8

    # Add terminator (max 4 bits)
    rem = max_bits - length(padded)
    if (rem >= 4) padded = padded "0000"

    # Pad with alternating bytes
    pad_byte = 236  # 11101100 in decimal
    rem = max_bits - length(padded)
    while (rem >= 8) {
        pad_copy = pad_byte  # Use copy for bit extraction
        for (bit = 7; bit >= 0; bit--) {
            p = pw2(bit)
            padded = padded ((pad_copy >= p) ? "1" : "0")
            if (pad_copy >= p) pad_copy -= p
        }
        pad_byte = (pad_byte == 236) ? 17 : 236  # alternate
        rem = max_bits - length(padded)
    }

    return padded
}

# Convert bit string to byte array
# For QR, the bit string is: mode(4) + count(8) + data + terminator + padding
# We need to skip the first 12 bits (mode + count) when extracting data bytes
function bits_to_bytes(bits, bytes, skip,    i, j, byte, n, pos) {
    n = int(length(bits) / 8)
    for (i = 0; i < n; i++) {
        byte = 0
        pos = skip + i * 8
        for (j = 0; j < 8; j++) {
            if (substr(bits, pos + j + 1, 1) == "1")
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
    # Standard ASCII printable characters (space to ~)
    # AWK string: space is position 1, '!' is 2, etc.
    # ASCII: space=32, '!'=33, ... '~'=126
    s = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    return index(s, c) > 0 ? index(s, c) + 31 : 0
}

# Reed-Solomon encode
function rs_encode(data_bytes, data_len, ec_len, result,    gen, i, j, coef, orig) {
    # Save original data bytes (Python returns original data, not modified poly)
    for (i = 0; i < data_len; i++) orig[i] = data_bytes[i]

    # Initialize result with data + zeros (working polynomial)
    for (i = 0; i < data_len; i++) result[i] = data_bytes[i]
    for (i = data_len; i < data_len + ec_len; i++) result[i] = 0

    # Generator polynomial: precomputed for each ec_len
    init_gen_poly(gen, ec_len)

    # Polynomial division
    for (i = 0; i < data_len; i++) {
        coef = result[i]
        if (coef != 0) {
            # Note: loop goes j=0 to j<=ec_len (ec_len+1 iterations), matching Python
            for (j = 0; j <= ec_len; j++) {
                if (gen[j] != 0) {
                    # Use i+j (not i+j+1), matching Python's poly[i+j] ^= ...
                    result[i + j] = gf_xor(result[i + j], gf_mul(coef, gen[j]))
                }
            }
        }
    }

    # Restore original data bytes (Python returns original data + EC, not modified poly)
    for (i = 0; i < data_len; i++) result[i] = orig[i]

    # EC codewords are now in result[data_len ... data_len+ec_len-1]
    return data_len + ec_len
}

# Initialize generator polynomial for given ec_len
function init_gen_poly(gen, ec_len,    i) {
    # Precomputed generator polynomials (matching Python/qrcode library)
    # gen[0..ec_len] coefficients

    # For ec_len = 7 (V1):
    if (ec_len == 7) {
        gen[0] = 1;  gen[1] = 127; gen[2] = 122; gen[3] = 154; gen[4] = 164; gen[5] = 11;  gen[6] = 68;  gen[7] = 117
        return
    }
    # For ec_len = 10 (V2):
    if (ec_len == 10) {
        gen[0] = 1;  gen[1] = 216; gen[2] = 194; gen[3] = 159; gen[4] = 111; gen[5] = 199; gen[6] = 94;  gen[7] = 95;  gen[8] = 113; gen[9] = 157; gen[10] = 193
        return
    }
    # For ec_len = 15 (V3):
    if (ec_len == 15) {
        gen[0] = 1;   gen[1] = 87;  gen[2] = 229; gen[3] = 146; gen[4] = 77;  gen[5] = 224; gen[6] = 248; gen[7] = 120; gen[8] = 77;  gen[9] = 120; gen[10] = 61;  gen[11] = 91;  gen[12] = 110; gen[13] = 45;  gen[14] = 50;  gen[15] = 59
        return
    }
    # For ec_len = 20 (V4):
    if (ec_len == 20) {
        gen[0] = 1;  gen[1] = 87;  gen[2] = 229; gen[3] = 146; gen[4] = 77;  gen[5] = 224; gen[6] = 248; gen[7] = 120; gen[8] = 77;  gen[9] = 120; gen[10] = 61;  gen[11] = 91;  gen[12] = 110; gen[13] = 45;  gen[14] = 50;  gen[15] = 59;  gen[16] = 46;  gen[17] = 43;  gen[18] = 78;  gen[19] = 38;  gen[20] = 51
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
    mask = 7  # Use mask 7 to match Python qrencode.py

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
    # Finder pattern areas - the 7x7 inner region of each corner
    if (row < 7 && col < 7) return 1         # top-left finder area
    if (row < 7 && col >= size - 7) return 1    # top-right finder area
    if (row >= size - 7 && col < 7) return 1   # bottom-left finder area
    # Bottom-right finder only for v2+ (size >= 25)
    if (size >= 25 && row >= size - 7 && col >= size - 7) return 1

    # Timing pattern - horizontal (row 6, cols 8 to size-9)
    if (row == 6 && col >= 8 && col < size - 8) return 1
    # Timing pattern - vertical (col 6, rows 8 to size-9)
    if (col == 6 && row >= 8 && row < size - 8) return 1

    # Separator row 7 around top-left finder (cols 0-8)
    if (row == 7 && col < 8) return 1
    # Separator row 7 around top-right finder (cols 13 to size-1)
    if (row == 7 && col >= 13) return 1
    # Separator row 13 around bottom-left finder (cols 0-8)
    if (row == 13 && col < 8) return 1
    # Separator row 13 around bottom-right finder (cols 13 to size-1, only for v2+)
    if (size >= 25 && row == 13 && col >= 13) return 1

    # Separator column 7 around top-left finder (rows 0-8)
    if (col == 7 && row < 8) return 1
    # Separator column 13 around top-right finder (rows 0-8)
    if (col == 13 && row < 8) return 1
    # Separator column 7 around bottom-left finder (rows 13-20)
    if (col == 7 && row >= size - 8) return 1
    # Separator column 14 around bottom-right finder (rows 13-20, only for v2+)
    if (size >= 25 && col == 14 && row >= size - 8) return 1

    # Format information positions (ISO 18004)
    # Row 8: col 20-13 (horizontal format bits 0-7)
    if (row == 8 && col >= 13 && col <= 20) return 1
    # Row 8: col 7,5,4,3,2,1,0 (horizontal format bits 8-14)
    if (row == 8 && (col == 7 || col == 5 || col == 4 || col == 3 || col == 2 || col == 1 || col == 0)) return 1
    # Row 7: col 8 (format bit 6)
    if (row == 7 && col == 8) return 1
    # Row 8: col 8 (format bit 7)
    if (row == 8 && col == 8) return 1
    # Col 8: rows 0-5 (vertical format bits 0-5)
    if (col == 8 && row >= 0 && row <= 5) return 1
    # Col 8: rows 14-20 (vertical format bits 8-14)
    if (col == 8 && row >= 14 && row <= 20) return 1

    # Fixed module at (size-8, 8) - always 1
    if (row == size - 8 && col == 8) return 1

    return 0
}

function place_data(matrix, size, data, data_len, mask,    bit_idx, col, row, inc, byte_idx, bit, byte_val, col_pair, placed, done) {
    bit_idx = 0
    row = size - 1
    inc = -1

    for (col = size - 1; col >= 1; col -= 2) {
        # Adjust col to skip timing column (col 6)
        if (col == 6) col = 5

        col_pair = col - 1  # Second column in the pair

        while (1) {
            placed = 0

            # Process both columns in the pair at current row
            if (!is_reserved(row, col, size)) {
                byte_idx = int(bit_idx / 8)
                if (byte_idx < data_len) {
                    bit = 7 - (bit_idx % 8)
                    byte_val = data[byte_idx]
                    byte_val = get_bit(byte_val, bit)
                    if (get_mask_bit(row, col, mask))
                        byte_val = 1 - byte_val
                    matrix[row, col] = byte_val
                    bit_idx++
                    placed = 1
                }
            }

            if (!is_reserved(row, col_pair, size)) {
                byte_idx = int(bit_idx / 8)
                if (byte_idx < data_len) {
                    bit = 7 - (bit_idx % 8)
                    byte_val = data[byte_idx]
                    byte_val = get_bit(byte_val, bit)
                    if (get_mask_bit(row, col_pair, mask))
                        byte_val = 1 - byte_val
                    matrix[row, col_pair] = byte_val
                    bit_idx++
                    placed = 1
                }
            }

            # Move row in current direction
            row += inc

            # Check if we hit a boundary and need to reverse
            if (row < 0 || row >= size) {
                row -= inc  # Back up
                inc = -inc  # Reverse direction
                break
            }

            # If no data placed in this iteration and we didn't hit boundary,
            # we must be stuck at reserved areas - continue to next row
            if (!placed) {
                continue
            }

            # Check if data is exhausted
            byte_idx = int(bit_idx / 8)
            if (byte_idx >= data_len) {
                done = 1
                break
            }
        }

        if (done) break
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
    # Format information placement matching qrcode library exactly:
    # Horizontal (row 8): col 20 down to col 13 for bits 0-7
    for (i = 0; i < 8; i++) {
        matrix[8, 20 - i] = substr(format_bits, i+1, 1) + 0
    }

    # Row 8, remaining: col 7 (bit 8), col 5 (bit 9), col 4 (bit 10),
    # col 3 (bit 11), col 2 (bit 12), col 1 (bit 13), col 0 (bit 14)
    matrix[8, 7] = substr(format_bits, 9, 1) + 0
    matrix[8, 5] = substr(format_bits, 10, 1) + 0
    matrix[8, 4] = substr(format_bits, 11, 1) + 0
    matrix[8, 3] = substr(format_bits, 12, 1) + 0
    matrix[8, 2] = substr(format_bits, 13, 1) + 0
    matrix[8, 1] = substr(format_bits, 14, 1) + 0
    matrix[8, 0] = substr(format_bits, 15, 1) + 0

    # Row 7, col 8: format[6]
    matrix[7, 8] = substr(format_bits, 7, 1) + 0

    # Row 8, col 8: format[7]
    matrix[8, 8] = substr(format_bits, 8, 1) + 0

    # Vertical (col 8, rows 0-5): format[0-5]
    for (i = 0; i < 6; i++) {
        matrix[i, 8] = substr(format_bits, i+1, 1) + 0
    }

    # Bottom vertical (col 8, rows 14-20): format[8-14]
    for (i = 0; i < 7; i++) {
        matrix[14 + i, 8] = substr(format_bits, 9 + i, 1) + 0
    }

    # Fixed module at (size-8, 8) - always 1
    matrix[size - 8, 8] = 1
}

function add_version(matrix, size, version,    i) {
    # Version info is placed in 3 positions around finder patterns
    # For version 7+
    if (version >= 7) {
        # This is a simplified version - full implementation would need more complex placement
    }
}

# Render QR code to terminal using half blocks to pack 2 rows per visual line
function render_raw(matrix, size,    i, j) {
    for (i = 0; i < size; i++) {
        line = ""
        for (j = 0; j < size; j++) {
            line = line (matrix[i, j] ? "1" : "0")
        }
        print line
    }
}

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
function qr_encode(data,    version, bits, padded, n_bytes, bytes_arr, ec_len, result, total_len, size, i, data_len, pad_byte) {
    version = get_version(length(data))
    ec_len = get_ec_codewords(version)

    bits = encode_data(data, version)
    padded = pad_bits(bits, version)
    # n_bytes is the data capacity (total codewords for this version)
    n_bytes = CAPACITY[version]

    # Extract all n_bytes bytes from padded bit string
    # The padded bit string already contains the pad pattern, so no separate padding needed
    bits_to_bytes(padded, bytes_arr, 0)

    total_len = rs_encode(bytes_arr, n_bytes, ec_len, result)

    size = build_matrix(result, total_len, version, matrix)
    if (DEBUG) {
        render_raw(matrix, size)
    } else {
        render(matrix, size)
    }
}

# Main entry point when run via awk
BEGIN {
    DEBUG = (DEBUG == "") ? 0 : DEBUG  # 0=no debug, 1=raw matrix, 2=verbose
    if (DATA != "") {
        qr_encode(DATA)
        exit
    }
}
