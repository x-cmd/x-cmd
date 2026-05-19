# QR Code Encoder - Pure AWK Implementation
# Uses precompiled GF(256) tables for multiplication and bitwise ops

BEGIN {
    # GF(256) tables - exp_tbl[i] = 2^i in GF(256), log_tbl[a] = exponent i where exp_tbl[i] = a
    split("1 2 4 8 16 32 64 128 29 58 116 232 205 135 19 38 76 152 45 90 180 117 234 201 143 3 6 12 24 48 96 192 157 39 78 156 37 74 148 53 106 212 181 119 238 193 159 35 70 140 5 10 20 40 80 160 93 186 105 210 185 111 222 161 95 190 97 194 153 47 94 188 101 202 137 15 30 60 120 240 253 231 211 187 107 214 177 127 254 225 223 163 91 182 113 226 217 175 67 134 17 34 68 136 13 26 52 104 208 189 103 206 129 31 62 124 248 237 199 147 59 118 236 197 151 51 102 204 133 23 46 92 184 109 218 169 79 158 33 66 132 21 42 84 168 77 154 41 82 164 85 170 73 146 57 114 228 213 183 115 230 209 191 99 198 145 63 126 252 229 215 179 123 246 241 255 227 219 171 75 150 49 98 196 149 55 110 220 165 87 174 65 130 25 50 100 200 141 7 14 28 56 112 224 221 167 83 166 81 162 89 178 121 242 249 239 195 155 43 86 172 69 138 9 18 36 72 144 61 122 244 245 247 243 251 235 203 139 11 22 44 88 176 125 250 233 207 131 27 54 108 216 173 71 142 1", exp_tbl)
    split("0 1 25 2 50 26 198 3 223 51 238 27 104 199 75 4 100 224 14 52 141 239 129 28 193 105 248 200 8 76 113 5 138 101 47 225 36 15 33 53 147 142 218 240 18 130 69 29 181 194 125 106 39 249 185 201 154 9 120 77 228 114 166 6 191 139 98 102 221 48 253 226 152 37 179 16 145 34 136 54 208 148 206 143 150 219 189 241 210 19 92 131 56 70 64 30 66 182 163 195 72 126 110 107 58 40 84 250 133 186 61 202 94 155 159 10 21 121 43 78 212 229 172 115 243 167 87 7 112 192 247 140 128 99 13 103 74 222 237 49 197 254 24 227 165 153 119 38 184 180 124 17 68 146 217 35 32 137 46 55 63 209 91 149 188 207 205 144 135 151 178 220 252 190 97 242 86 211 171 20 42 93 158 132 60 57 83 71 109 65 162 31 45 67 216 183 123 164 118 196 23 73 236 127 12 111 246 108 161 59 82 41 157 85 170 251 96 134 177 187 204 62 90 203 89 95 176 156 169 160 81 11 245 22 235 122 117 44 215 79 174 213 233 230 231 173 232 116 214 244 234 168 80 88 175", log_tbl)
    # QR Version 1-15 capacity tables (Byte mode, EC Level L)
    #
    # Byte mode data capacity (max URL/data length) per version:
    #   V1  17B   V2  32B   V3  53B   V4  78B   V5 106B
    #   V6 134B   V7 154B   V8 192B   V9 230B   V10 271B
    #   V11 321B  V12 367B  V13 425B  V14 458B  V15 520B
    #
    # version -> total data codewords (matching Python CAPACITY)
    CAPACITY[1] = 19
    CAPACITY[2] = 34
    CAPACITY[3] = 55
    CAPACITY[4] = 80
    CAPACITY[5] = 108
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

    # EC codewords per block for L level (from Python qrcode base.rs_blocks)
    EC_L[1] = 7;   EC_L[2] = 10;  EC_L[3] = 15;  EC_L[4] = 20
    EC_L[5] = 26;  EC_L[6] = 18;  EC_L[7] = 20;  EC_L[8] = 24
    EC_L[9] = 30;  EC_L[10] = 18; EC_L[11] = 20; EC_L[12] = 24
    EC_L[13] = 26; EC_L[14] = 30; EC_L[15] = 22

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

    # Number of RS blocks per version at EC Level L
    RS_BLOCKS[1] = 1;   RS_BLOCKS[2] = 1;   RS_BLOCKS[3] = 1;   RS_BLOCKS[4] = 1
    RS_BLOCKS[5] = 1;   RS_BLOCKS[6] = 2;   RS_BLOCKS[7] = 2;   RS_BLOCKS[8] = 2
    RS_BLOCKS[9] = 2;   RS_BLOCKS[10] = 4;  RS_BLOCKS[11] = 4;  RS_BLOCKS[12] = 4
    RS_BLOCKS[13] = 4;  RS_BLOCKS[14] = 4;  RS_BLOCKS[15] = 6
}

# Byte XOR - use gawk's native xor() for correctness
function gf_xor(a, b) {
    return xor(a, b)
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
        gen[0] = 1;   gen[1] = 29;  gen[2] = 196; gen[3] = 111; gen[4] = 163; gen[5] = 112; gen[6] = 74;  gen[7] = 10;  gen[8] = 105; gen[9] = 105; gen[10] = 139; gen[11] = 132; gen[12] = 151; gen[13] = 32;  gen[14] = 134; gen[15] = 26
        return
    }
    # For ec_len = 20 (V4):
    if (ec_len == 20) {
        gen[0] = 1;   gen[1] = 152; gen[2] = 185; gen[3] = 240; gen[4] = 5;   gen[5] = 111; gen[6] = 99;  gen[7] = 6;   gen[8] = 220; gen[9] = 112; gen[10] = 150; gen[11] = 69;  gen[12] = 36;  gen[13] = 187; gen[14] = 22;  gen[15] = 228; gen[16] = 198; gen[17] = 121; gen[18] = 121; gen[19] = 165; gen[20] = 174
        return
    }
    # For ec_len = 26 (V5):
    if (ec_len == 26) {
        gen[0] = 1;   gen[1] = 246; gen[2] = 51;  gen[3] = 183; gen[4] = 4;   gen[5] = 136; gen[6] = 98;  gen[7] = 199; gen[8] = 152; gen[9] = 77;  gen[10] = 56;  gen[11] = 206; gen[12] = 24;  gen[13] = 145; gen[14] = 40;  gen[15] = 209; gen[16] = 117; gen[17] = 233; gen[18] = 42;  gen[19] = 135; gen[20] = 68;  gen[21] = 70;  gen[22] = 144; gen[23] = 146; gen[24] = 77;  gen[25] = 43;  gen[26] = 94
        return
    }
    # For ec_len = 18 (V6-V10 blocks):
    if (ec_len == 18) {
        gen[0] = 1;   gen[1] = 239; gen[2] = 251; gen[3] = 183; gen[4] = 113; gen[5] = 149; gen[6] = 175; gen[7] = 199; gen[8] = 215; gen[9] = 240; gen[10] = 220; gen[11] = 73;  gen[12] = 82;  gen[13] = 173; gen[14] = 75;  gen[15] = 32;  gen[16] = 67;  gen[17] = 217; gen[18] = 146
        return
    }
    # For ec_len = 24 (V8, V12 blocks):
    if (ec_len == 24) {
        gen[0] = 1;   gen[1] = 122; gen[2] = 118; gen[3] = 169; gen[4] = 70;  gen[5] = 178; gen[6] = 237; gen[7] = 216; gen[8] = 102; gen[9] = 115; gen[10] = 150; gen[11] = 229; gen[12] = 73;  gen[13] = 130; gen[14] = 72;  gen[15] = 61;  gen[16] = 43;  gen[17] = 206; gen[18] = 1;   gen[19] = 237; gen[20] = 247; gen[21] = 127; gen[22] = 217; gen[23] = 144; gen[24] = 117
        return
    }
    # For ec_len = 22 (V15 blocks):
    if (ec_len == 22) {
        gen[0] = 1;   gen[1] = 89;  gen[2] = 179; gen[3] = 131; gen[4] = 176; gen[5] = 182; gen[6] = 244; gen[7] = 19;  gen[8] = 189; gen[9] = 69;  gen[10] = 40;  gen[11] = 28;  gen[12] = 137; gen[13] = 29;  gen[14] = 123; gen[15] = 67;  gen[16] = 253; gen[17] = 86;  gen[18] = 218; gen[19] = 230; gen[20] = 26;  gen[21] = 145; gen[22] = 245
        return
    }
    # For ec_len = 28 (V14-V15 blocks):
    if (ec_len == 28) {
        gen[0] = 1;   gen[1] = 252; gen[2] = 9;   gen[3] = 28;  gen[4] = 13;  gen[5] = 18;  gen[6] = 251; gen[7] = 208; gen[8] = 150; gen[9] = 103; gen[10] = 174; gen[11] = 100; gen[12] = 41;  gen[13] = 167; gen[14] = 12;  gen[15] = 247; gen[16] = 56;  gen[17] = 117; gen[18] = 119; gen[19] = 233; gen[20] = 127; gen[21] = 181; gen[22] = 100; gen[23] = 121; gen[24] = 147; gen[25] = 176; gen[26] = 74;  gen[27] = 58;  gen[28] = 197
        return
    }
    # For ec_len = 30 (V9, V13 blocks):
    if (ec_len == 30) {
        gen[0] = 1;   gen[1] = 212; gen[2] = 246; gen[3] = 77;  gen[4] = 73;  gen[5] = 195; gen[6] = 192; gen[7] = 75;  gen[8] = 98;  gen[9] = 5;   gen[10] = 70;  gen[11] = 103; gen[12] = 177; gen[13] = 22;  gen[14] = 217; gen[15] = 138; gen[16] = 51;  gen[17] = 181; gen[18] = 246; gen[19] = 72;  gen[20] = 25;  gen[21] = 18;  gen[22] = 46;  gen[23] = 228; gen[24] = 74;  gen[25] = 216; gen[26] = 195; gen[27] = 11;  gen[28] = 106; gen[29] = 130; gen[30] = 150
        return
    }
    # Fallback: compute dynamically (corrected order)
    gen[0] = 1
    for (i = 1; i <= ec_len; i++) gen[i] = 0

    # Multiply by (x - a^i) for i = 0 to ec_len-1
    for (i = 0; i < ec_len; i++) {
        for (j = ec_len; j > 0; j--) {
            gen[j] = gf_xor(gf_mul(gen[j], exp_tbl[i+1]), gen[j-1])
        }
        gen[0] = gf_mul(gen[0], exp_tbl[i+1])
    }
    # Reverse to get correct coefficient order (highest degree first)
    for (i = 0; i < int(ec_len / 2); i++) {
        tmp = gen[i]
        gen[i] = gen[ec_len - i]
        gen[ec_len - i] = tmp
    }
}

# Build QR matrix
function build_matrix(result, total_len, version,    matrix, size, i, j, bit_idx, mask) {
    size = MATRIX_SIZE[version]
    mask = 7  # Use mask 7 to match Python qrencode.py
    VERSION = version  # Global for is_reserved

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

function add_alignment(matrix, version, size,    pos, npos, i, j, k, cr, cc, n, step) {
    # Alignment pattern center coordinates per ISO 18004 Annex E
    # version 1 has no alignment patterns (handled by caller check)
    if (version == 2) { n = 2; pos[0] = 6; pos[1] = 18 }
    else if (version == 3) { n = 2; pos[0] = 6; pos[1] = 22 }
    else if (version == 4) { n = 2; pos[0] = 6; pos[1] = 26 }
    else if (version == 5) { n = 2; pos[0] = 6; pos[1] = 30 }
    else if (version == 6) { n = 2; pos[0] = 6; pos[1] = 34 }
    else if (version == 7) { n = 3; pos[0] = 6; pos[1] = 22; pos[2] = 38 }
    else if (version == 8) { n = 3; pos[0] = 6; pos[1] = 24; pos[2] = 42 }
    else if (version == 9) { n = 3; pos[0] = 6; pos[1] = 26; pos[2] = 46 }
    else if (version == 10) { n = 3; pos[0] = 6; pos[1] = 28; pos[2] = 50 }
    else if (version == 11) { n = 3; pos[0] = 6; pos[1] = 30; pos[2] = 54 }
    else if (version == 12) { n = 3; pos[0] = 6; pos[1] = 32; pos[2] = 58 }
    else if (version == 13) { n = 3; pos[0] = 6; pos[1] = 34; pos[2] = 62 }
    else if (version == 14) { n = 4; pos[0] = 6; pos[1] = 26; pos[2] = 46; pos[3] = 66 }
    else if (version == 15) { n = 4; pos[0] = 6; pos[1] = 26; pos[2] = 48; pos[3] = 70 }
    else {
        # Generic formula for versions 16+
        n = int(version / 7) + 2
        step = int((size - 12) / (n - 1))
        step = step - (step % 2)  # ensure even step
        for (i = 0; i < n - 1; i++) {
            pos[i] = 6 + i * step
        }
        pos[n-1] = size - 7
    }

    # Store alignment positions for is_reserved
    ALIGN_N = n
    for (i = 0; i < n; i++) ALIGN_POS[i] = pos[i]

    # Draw alignment patterns at each grid intersection
    # Skip positions that overlap with finder patterns
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++) {
            cr = pos[i]  # row center
            cc = pos[j]  # col center

            # Skip if overlapping with any finder pattern
            if (cr <= 8 && cc <= 8) continue         # top-left
            if (cr <= 8 && cc >= size - 8) continue   # top-right
            if (cr >= size - 8 && cc <= 8) continue   # bottom-left

            # Draw 5x5 alignment pattern centered at (cr, cc)
            for (k = -2; k <= 2; k++) {
                matrix[cr + k, cc - 2] = 1
                matrix[cr + k, cc + 2] = 1
                matrix[cr - 2, cc + k] = 1
                matrix[cr + 2, cc + k] = 1
            }
            for (k = -1; k <= 1; k++) {
                for (m = -1; m <= 1; m++) {
                    if (k != 0 || m != 0) matrix[cr + k, cc + m] = 0
                }
            }
            matrix[cr, cc] = 1
        }
    }
}

function is_reserved(row, col, size) {
    # Finder pattern areas (7x7 at each corner)
    if (row < 7 && col < 7) return 1              # top-left
    if (row < 7 && col >= size - 7) return 1      # top-right
    if (row >= size - 7 && col < 7) return 1      # bottom-left

    # Timing pattern - horizontal (row 6, cols 8 to size-9)
    if (row == 6 && col >= 8 && col < size - 8) return 1
    # Timing pattern - vertical (col 6, rows 8 to size-9)
    if (col == 6 && row >= 8 && row < size - 8) return 1

    # Separator row around top finders
    if (row == 7 && col < 8) return 1             # top-left separator
    if (row == 7 && col >= size - 8) return 1     # top-right separator
    # Separator row around bottom finders
    if (row == size - 8 && col < 8) return 1      # bottom-left separator

    # Separator column around left finders
    if (col == 7 && row < 8) return 1             # top-left separator
    if (col == 7 && row >= size - 8) return 1     # bottom-left separator
    # Separator column around right finders
    if (col == size - 8 && row < 8) return 1      # top-right separator

    # Format information positions (ISO 18004)
    # Row 8: col (size-8) to (size-1) (horizontal format bits 0-7)
    if (row == 8 && col >= size - 8 && col <= size - 1) return 1
    # Row 8: col 7,5,4,3,2,1,0 (horizontal format bits 8-14)
    if (row == 8 && (col == 7 || col == 5 || col == 4 || col == 3 || col == 2 || col == 1 || col == 0)) return 1
    # Row 7: col 8 (format bit 6)
    if (row == 7 && col == 8) return 1
    # Row 8: col 8 (format bit 7)
    if (row == 8 && col == 8) return 1
    # Col 8: rows 0-5 (vertical format bits 0-5)
    if (col == 8 && row >= 0 && row <= 5) return 1
    # Col 8: rows (size-7) to (size-1) (vertical format bits 8-14)
    if (col == 8 && row >= size - 7 && row <= size - 1) return 1

    # Fixed module at (size-8, 8) - always dark
    if (row == size - 8 && col == 8) return 1

    # Version info areas (version 7+): 6x3 blocks near top-right and bottom-left
    if (VERSION >= 7) {
        # Top-right: rows 0-5, cols (size-11) to (size-9)
        if (row < 6 && col >= size - 11 && col <= size - 9) return 1
        # Bottom-left: rows (size-11) to (size-9), cols 0-5
        if (row >= size - 11 && row <= size - 9 && col < 6) return 1
    }

    # Alignment pattern areas (5x5 around each alignment center)
    if (ALIGN_N > 0) {
        for (ar = 0; ar < ALIGN_N; ar++) {
            for (ac = 0; ac < ALIGN_N; ac++) {
                cr = ALIGN_POS[ar]
                cc = ALIGN_POS[ac]
                # Skip finder pattern overlaps
                if (cr <= 8 && cc <= 8) continue
                if (cr <= 8 && cc >= size - 8) continue
                if (cr >= size - 8 && cc <= 8) continue
                if (row >= cr - 2 && row <= cr + 2 && col >= cc - 2 && col <= cc + 2) return 1
            }
        }
    }

    return 0
}

function place_data(matrix, size, data, data_len, mask,    bit_idx, col, row, inc, byte_idx, bit, byte_val, col_pair, placed) {
    bit_idx = 0
    row = size - 1
    inc = -1

    for (col = size - 1; col >= 1; col -= 2) {
        # Adjust col to skip timing column (col 6)
        if (col == 6) col = 5

        col_pair = col - 1  # Second column in the pair

        while (1) {
            placed = 0

            # Process right column (col) at current row
            if (!is_reserved(row, col, size)) {
                byte_idx = int(bit_idx / 8)
                if (byte_idx < data_len) {
                    bit = 7 - (bit_idx % 8)
                    byte_val = data[byte_idx]
                    byte_val = get_bit(byte_val, bit)
                } else {
                    byte_val = 0
                }
                if (get_mask_bit(row, col, mask))
                    byte_val = 1 - byte_val
                matrix[row, col] = byte_val
                bit_idx++
                placed = 1
            }

            # Process left column (col_pair) at current row
            if (!is_reserved(row, col_pair, size)) {
                byte_idx = int(bit_idx / 8)
                if (byte_idx < data_len) {
                    bit = 7 - (bit_idx % 8)
                    byte_val = data[byte_idx]
                    byte_val = get_bit(byte_val, bit)
                } else {
                    byte_val = 0
                }
                if (get_mask_bit(row, col_pair, mask))
                    byte_val = 1 - byte_val
                matrix[row, col_pair] = byte_val
                bit_idx++
                placed = 1
            }

            # Move row in current direction
            row += inc

            # Check if we hit a boundary and need to reverse
            if (row < 0 || row >= size) {
                row -= inc  # Back up
                inc = -inc  # Reverse direction
                break
            }

            # If no data cells in this row, continue to next row
            if (!placed) {
                continue
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
    # Format information placement per ISO 18004:
    # Horizontal (row 8): col (size-1) down to col (size-8) for bits 0-7
    for (i = 0; i < 8; i++) {
        matrix[8, (size - 1) - i] = substr(format_bits, i+1, 1) + 0
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

    # Bottom vertical (col 8, rows (size-7) to (size-1)): format[8-14]
    for (i = 0; i < 7; i++) {
        matrix[(size - 7) + i, 8] = substr(format_bits, 9 + i, 1) + 0
    }

    # Fixed module at (size-8, 8) - always 1
    matrix[size - 8, 8] = 1
}

function add_version(matrix, size, version,    i, bits, mod) {
    # Version info (18-bit BCH) placed for version 7+
    # Precomputed values from Python qrcode.util.BCH_type_number()
    if (version == 7) bits = 31892
    else if (version == 8) bits = 34236
    else if (version == 9) bits = 39577
    else if (version == 10) bits = 42195
    else if (version == 11) bits = 48118
    else if (version == 12) bits = 51042
    else if (version == 13) bits = 55367
    else if (version == 14) bits = 58893
    else if (version == 15) bits = 63784
    else return

    # Top-right: row=i/3, col=i%3 + size-11 (for i=0..17)
    # Bottom-left: row=i%3 + size-11, col=i/3 (for i=0..17)
    # bits >> i & 1 gives LSB-first version info
    for (i = 0; i < 18; i++) {
        mod = int(bits / pw2(i)) % 2
        # Top-right version info block
        matrix[int(i / 3), (i % 3) + size - 11] = mod
        # Bottom-left version info block (transposed)
        matrix[(i % 3) + size - 11, int(i / 3)] = mod
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
function qr_encode(data,    version, bits, padded, n_bytes, bytes_arr, ec_len, result, total_len, size, i, n_blocks, dc_per_block, b, offset, block_result, block_ec) {
    version = get_version(length(data))
    ec_len = get_ec_codewords(version)
    n_blocks = RS_BLOCKS[version]

    bits = encode_data(data, version)
    padded = pad_bits(bits, version)
    # n_bytes is the data capacity (total data codewords for this version)
    n_bytes = CAPACITY[version]

    # Extract all n_bytes bytes from padded bit string
    bits_to_bytes(padded, bytes_arr, 0)

    if (n_blocks == 1) {
        # Single block: simple case
        total_len = rs_encode(bytes_arr, n_bytes, ec_len, result)
    } else {
        # Multi-block: split data, RS encode each block, interleave
        # Some versions have uneven block sizes (e.g., V10: [68,68,69,69])
        dc_small = int(n_bytes / n_blocks)
        n_large = n_bytes - dc_small * n_blocks  # number of blocks with dc_small+1

        # RS encode each block separately
        offset = 0
        for (b = 0; b < n_blocks; b++) {
            if (b < n_blocks - n_large) {
                dc_this = dc_small
            } else {
                dc_this = dc_small + 1
            }
            for (i = 0; i < dc_this; i++) {
                block_result[b, i] = bytes_arr[offset + i]
            }
            rs_encode_block(block_result, b, dc_this, ec_len)
            offset += dc_this
        }

        # Interleave: data bytes round-robin (skip blocks where i >= len)
        # Then EC bytes round-robin
        total_len = 0
        max_dc = dc_small + (n_large > 0 ? 1 : 0)
        for (i = 0; i < max_dc; i++) {
            for (b = 0; b < n_blocks; b++) {
                if (b < n_blocks - n_large) {
                    dc_this = dc_small
                } else {
                    dc_this = dc_small + 1
                }
                if (i < dc_this) {
                    result[total_len++] = block_result[b, i]
                }
            }
        }
        for (i = 0; i < ec_len; i++) {
            for (b = 0; b < n_blocks; b++) {
                if (b < n_blocks - n_large) {
                    dc_this = dc_small
                } else {
                    dc_this = dc_small + 1
                }
                result[total_len++] = block_result[b, dc_this + i]
            }
        }
    }

    size = build_matrix(result, total_len, version, matrix)
    if (DEBUG) {
        render_raw(matrix, size)
    } else {
        render(matrix, size)
    }
}

# RS encode a single block: data in block_result[block_idx, 0..dc-1],
# EC result in block_result[block_idx, dc..dc+ec_len-1]
function rs_encode_block(block_result, block_idx, dc, ec_len,    gen, i, j, coef, orig) {
    # Save original data
    for (i = 0; i < dc; i++) orig[i] = block_result[block_idx, i]

    # Initialize: data + zeros for EC
    for (i = dc; i < dc + ec_len; i++) block_result[block_idx, i] = 0

    # Generator polynomial
    init_gen_poly(gen, ec_len)

    # Polynomial division
    for (i = 0; i < dc; i++) {
        coef = block_result[block_idx, i]
        if (coef != 0) {
            for (j = 0; j <= ec_len; j++) {
                if (gen[j] != 0) {
                    block_result[block_idx, i + j] = gf_xor(block_result[block_idx, i + j], gf_mul(coef, gen[j]))
                }
            }
        }
    }

    # Restore original data bytes
    for (i = 0; i < dc; i++) block_result[block_idx, i] = orig[i]
}

# Main entry point when run via awk
BEGIN {
    DEBUG = (DEBUG == "") ? 0 : DEBUG  # 0=no debug, 1=raw matrix, 2=verbose
    if (DATA != "") {
        qr_encode(DATA)
        exit
    }
}
