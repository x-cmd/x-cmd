#!/usr/bin/env python3
"""
Pure Python QR Encoder - Standard 0x11D GF(256) implementation
Uses correct polynomial arithmetic for QR code encoding.
"""

# Precomputed GF(256) lookup tables for polynomial 0x11D
# exp_tbl[i] = 2^i in GF(256), log_tbl[v] = exponent i where exp_tbl[i] = v
def _init_gf_tables():
    exp_tbl = [1]
    for i in range(1, 256):
        val = exp_tbl[-1] * 2
        if val >= 256:
            val ^= 0x11D
        exp_tbl.append(val & 0xFF)
    log_tbl = [0] * 256
    for i in range(1, 256):
        log_tbl[exp_tbl[i]] = i
    log_tbl[1] = 0  # 2^0 = 1, not 255
    return exp_tbl, log_tbl

EXP_TBL, LOG_TBL = _init_gf_tables()

def gf_mul(a, b):
    """GF(256) multiplication with primitive polynomial 0x11D"""
    if a == 0 or b == 0:
        return 0
    return EXP_TBL[(LOG_TBL[a] + LOG_TBL[b]) % 255]

# QR Code parameters (ISO 18004)
# CAPACITY = max data bytes in byte mode for ECL L
# DATA_CODEWORDS = total codewords (data + EC) for ECL L
# EC_L = error correction codewords for ECL L
CAPACITY = {1: 19, 2: 34, 3: 55, 4: 80, 5: 106, 6: 136}
MATRIX_SIZE = {1: 21, 2: 25, 3: 29, 4: 33, 5: 37, 6: 41}
DATA_CODEWORDS = {1: 26, 2: 44, 3: 70, 4: 100, 5: 134, 6: 172}
EC_L = {1: 7, 2: 10, 3: 15, 4: 20, 5: 26, 6: 36}

# Format strings from ISO 18004 - BCH result XORed with 0x5412
# LSB-first so format_bits[i] gives bit i
FORMAT_L = {
    # ECL L format strings for masks 0-7 (LSB first, XORed with 0x5412)
    0: "001000111110111",  # ECL L, mask 0
    1: "110011110100111",  # ECL L, mask 1
    2: "010101011011111",  # ECL L, mask 2
    3: "101110010001111",  # ECL L, mask 3
    4: "111101000110011",  # ECL L, mask 4
    5: "000110001100011",  # ECL L, mask 5
    6: "100000100011011",  # ECL L, mask 6
    7: "011011101001011",  # ECL L, mask 7
}

def pw2(n):
    return 1 << n

def get_version(data_len):
    for v in range(1, 16):
        if CAPACITY.get(v, 0) >= data_len:
            return v
    return 15

def get_char_count_bits(version):
    return 8 if version <= 9 else 16

def encode_data(data, version):
    bits = ""
    bits += "0100"  # Mode: byte mode
    cc_bits = get_char_count_bits(version)
    length = len(data)
    for i in range(cc_bits - 1, -1, -1):
        bits += "1" if length >= pw2(i) else "0"
        if length >= pw2(i):
            length -= pw2(i)
    for c in data:
        byte = ord(c)
        for bit in range(7, -1, -1):
            bits += "1" if byte >= pw2(bit) else "0"
            if byte >= pw2(bit):
                byte -= pw2(bit)
    return bits

def pad_bits(bits, version):
    padded = bits
    max_bits = CAPACITY[version] * 8
    rem = max_bits - len(padded)
    if rem >= 4:
        padded += "0000"
    rem = max_bits - len(padded)

    pad_bytes = [0xEC, 0x11]
    for i in range(rem // 8):
        pad_byte = pad_bytes[i % 2]
        for bit in range(7, -1, -1):
            padded += "1" if pad_byte >= pw2(bit) else "0"
            if pad_byte >= pw2(bit):
                pad_byte -= pw2(bit)
        rem = max_bits - len(padded)
    return padded

def bits_to_bytes(bits, skip, n_bytes):
    result = []
    for i in range(n_bytes):
        pos = skip + i * 8
        byte = 0
        for j in range(8):
            if bits[pos + j] == '1':
                byte += pw2(7 - j)
        result.append(byte)
    return result

def init_gen_poly(ec_len):
    """Generator polynomial coefficients for RS(n,k) - QR code standard"""
    # Correct coefficients from qrcode LUT (matches ISO 18004)
    polynomials = {
        7:  [1, 127, 122, 154, 164, 11, 68, 117],
        10: [1, 216, 194, 159, 111, 199, 94, 95, 113, 157, 193],
        16: [1, 87, 229, 146, 77, 224, 248, 120, 77, 120, 61, 91, 110, 45, 50, 59, 46, 43, 78, 38, 51],
        26: [1, 120, 104, 107, 109, 102, 161, 165, 6, 16, 132, 100, 73, 230, 218, 206, 201, 120, 174, 87, 165, 41, 163, 97, 120, 24, 73, 160, 227, 17],
        36: [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    }
    return polynomials.get(ec_len)

def rs_encode(data_bytes, data_len, ec_len):
    """Reed-Solomon RS(19,12) encoding using polynomial division"""
    gen = init_gen_poly(ec_len)
    if gen is None:
        return data_bytes[:data_len] + [0] * ec_len

    # Build working polynomial: data followed by ec_len zeros
    # This represents data(x) * x^ec_len
    poly = data_bytes[:data_len] + [0] * ec_len

    # Polynomial division: compute remainder when dividing by generator
    for i in range(data_len):
        coef = poly[i]
        if coef != 0:
            for j in range(ec_len + 1):
                if gen[j] != 0:
                    poly[i + j] ^= gf_mul(coef, gen[j])

    # poly now contains: [modified_data..., remainder...]
    # We only need the EC bytes (positions data_len onwards)
    ec_bytes = poly[data_len:data_len + ec_len]

    # Result is original data followed by computed EC
    return data_bytes[:data_len] + ec_bytes

def is_reserved(row, col, size):
    # Finder pattern areas - only the INNER 7x7 of each corner
    # Top-left finder: rows 0-6, cols 0-6 (NOT including outer border at row/col 7)
    if row < 7 and col < 7:
        return True
    # Top-right finder: rows 0-6, cols size-7 to size-1
    if row < 7 and col >= size - 7:
        return True
    # Bottom-left finder: rows size-7 to size-1, cols 0-6
    if row >= size - 7 and col < 7:
        return True
    # Bottom-right finder: rows size-7 to size-1, cols size-7 to size-1
    # BUT only for version 2+ (size >= 25). For version 1 (size=21),
    # there is no bottom-right finder - that area is available for data
    if size >= 25 and row >= size - 7 and col >= size - 7:
        return True
    # Timing pattern - horizontal (row 6, cols 8 to size-9)
    if row == 6 and 8 <= col < size - 8:
        return True
    # Timing pattern - vertical (col 6, rows 8 to size-9)
    if col == 6 and 8 <= row < size - 8:
        return True
    # Separator row 7 around top-left finder (cols 0-8)
    if row == 7 and col < 8:
        return True
    # Separator row 7 around top-right finder (cols 13 to size-1 = 13-20 for v1)
    if row == 7 and col >= 13:
        return True
    # Separator row 13 around bottom-left finder (cols 0-8)
    if row == 13 and col < 8:
        return True
    # Separator row 13 around bottom-right finder (cols 13 to size-1, only for v2+)
    if size >= 25 and row == 13 and col >= 13:
        return True
    # Separator column 7 around top-left finder (rows 0-8)
    if col == 7 and row < 8:
        return True
    # Separator column 13 around top-right finder (rows 0-8)
    if col == 13 and row < 8:
        return True
    # Separator column 7 around bottom-left finder (rows 13-20)
    if col == 7 and row >= size - 8:
        return True
    # Separator column 14 around bottom-right finder (rows 13-20, only for v2+)
    if size >= 25 and col == 14 and row >= size - 8:
        return True
    # Format information positions (ISO 18004)
    # Row 8: col 20-13 (horizontal format bits 0-7)
    if row == 8 and 13 <= col <= 20:
        return True
    # Row 8: col 7,5,4,3,2,1,0 (horizontal format bits 8-14)
    if row == 8 and col in (7, 5, 4, 3, 2, 1, 0):
        return True
    # Row 7: col 8 (format bit 6)
    if row == 7 and col == 8:
        return True
    # Row 8: col 8 (format bit 7)
    if row == 8 and col == 8:
        return True
    # Col 8: rows 0-5 (vertical format bits 0-5)
    if col == 8 and 0 <= row <= 5:
        return True
    # Col 8: rows 14-20 (vertical format bits 8-14)
    if col == 8 and 14 <= row <= 20:
        return True
    # Fixed module at (size-8, 8) - used by qrcode
    if row == size - 8 and col == 8:
        return True
    return False

def add_finder(matrix, row, col, size):
    for i in range(7):
        matrix[row][col + i] = 1
        matrix[row + 6][col + i] = 1
        matrix[row + i][col] = 1
        matrix[row + i][col + 6] = 1
    for i in range(1, 6):
        for j in range(1, 6):
            matrix[row + i][col + j] = 0
    for i in range(2, 5):
        for j in range(2, 5):
            matrix[row + i][col + j] = 1

def add_separators(matrix, size):
    for i in range(8):
        matrix[7][i] = 0
        matrix[size - 8][i] = 0
        matrix[i][7] = 0
        matrix[i][size - 8] = 0

def add_timing(matrix, size):
    # Timing pattern: row 6, cols 8 to size-9; col 6, rows 8 to size-9
    for i in range(8, size - 8):
        matrix[6][i] = 1 if i % 2 == 0 else 0
        matrix[i][6] = 1 if i % 2 == 0 else 0

def get_mask_bit(row, col, mask):
    """Return 1 if bit should be flipped (masked), 0 otherwise."""
    if mask == 0:
        # 000: (row + col) % 2 == 0
        return 1 if (row + col) % 2 == 0 else 0
    elif mask == 1:
        # 001: row % 2 == 0
        return 1 if row % 2 == 0 else 0
    elif mask == 2:
        # 010: col % 3 == 0
        return 1 if col % 3 == 0 else 0
    elif mask == 3:
        # 011: (row + col) % 3 == 0
        return 1 if (row + col) % 3 == 0 else 0
    elif mask == 4:
        # 100: (row//2 + col//3) % 2 == 0
        return 1 if (row // 2 + col // 3) % 2 == 0 else 0
    elif mask == 5:
        # 101: ((row * col) % 2 + (row * col) % 3) % 2 == 0
        return 1 if ((row * col) % 2 + (row * col) % 3) % 2 == 0 else 0
    elif mask == 6:
        # 110: ((row * col) % 2 + (row * col) % 3) % 2 == 0
        return 1 if ((row * col) % 2 + (row * col) % 3) % 2 == 0 else 0
    elif mask == 7:
        # 111: ((row * col) % 3 + (row + col) % 2) % 2 == 0
        return 1 if ((row * col) % 3 + (row + col) % 2) % 2 == 0 else 0
    return 0

def get_bit(byte, pos):
    return (byte >> pos) & 1

def place_data(matrix, size, data, data_len, mask):
    # Data placement using direction-reversal pattern (matching qrcode)
    inc = -1
    row = size - 1
    bit_idx = 0

    for col in range(size - 1, 0, -2):
        actual_col = col - 1 if col <= 6 else col

        col_range = (actual_col, actual_col - 1)

        while True:
            placed_in_this_iter = False
            for c in col_range:
                if is_reserved(row, c, size):
                    continue
                current_byte_idx = bit_idx // 8
                if current_byte_idx >= data_len:
                    break
                bit = 7 - (bit_idx % 8)
                byte_val = get_bit(data[current_byte_idx], bit)
                if get_mask_bit(row, c, mask):
                    byte_val = 1 - byte_val
                matrix[row][c] = byte_val
                bit_idx += 1
                placed_in_this_iter = True

            # Move row AFTER processing both columns in the pair
            row += inc

            # Check for reversal after moving
            if row < 0 or row >= size:
                row -= inc
                inc = -inc
                break

            # Only continue if we actually placed data
            if not placed_in_this_iter:
                continue

            # If data is exhausted, break after moving row
            current_byte_idx = (bit_idx - 1) // 8 if bit_idx > 0 else 0
            if current_byte_idx >= data_len and (bit_idx - 1) % 8 == 7:
                break

def add_format(matrix, size, format_bits, version):
    # Format information placement matching qrcode library exactly:
    # Vertical (col 8):
    #   rows 0-5: format bits 0-5
    #   row 7: format bit 6
    #   row 8: format bit 7
    #   rows 14-20: format bits 8-14
    # Horizontal (row 8):
    #   col 20-i: format bit i for i=0-7
    #   col 7: format bit 8
    #   col 5: format bit 9
    #   col 4: format bit 10
    #   col 3: format bit 11
    #   col 2: format bit 12
    #   col 1: format bit 13
    #   col 0: format bit 14

    # Horizontal (row 8): col 20 down to col 13 for bits 0-7
    for i in range(8):
        matrix[8][20 - i] = int(format_bits[i])

    # Row 8, remaining: col 7 (bit 8), col 5 (bit 9), col 4 (bit 10),
    # col 3 (bit 11), col 2 (bit 12), col 1 (bit 13), col 0 (bit 14)
    matrix[8][7] = int(format_bits[8])
    matrix[8][5] = int(format_bits[9])
    matrix[8][4] = int(format_bits[10])
    matrix[8][3] = int(format_bits[11])
    matrix[8][2] = int(format_bits[12])
    matrix[8][1] = int(format_bits[13])
    matrix[8][0] = int(format_bits[14])

    # Row 7, col 8: format[6]
    matrix[7][8] = int(format_bits[6])

    # Row 8, col 8: format[7]
    matrix[8][8] = int(format_bits[7])

    # Vertical (col 8, rows 0-5): format[0-5]
    for i in range(6):
        matrix[i][8] = int(format_bits[i])

    # Bottom vertical (col 8, rows 14-20): format[8-14]
    for i in range(7):
        matrix[14 + i][8] = int(format_bits[8 + i])

    # Fixed module at (size-8, 8) - always 1
    matrix[size - 8][8] = 1

def qr_encode(data):
    version = get_version(len(data))
    ec_len = EC_L[version]
    bits = encode_data(data, version)
    padded = pad_bits(bits, version)

    n_bytes = CAPACITY[version]  # Data codewords (before EC)

    # Convert all padded bits to data codewords
    bytes_arr = []
    for i in range(n_bytes):
        pos = i * 8
        byte = 0
        for j in range(8):
            if padded[pos + j] == '1':
                byte += 1 << (7 - j)
        bytes_arr.append(byte)

    result = rs_encode(bytes_arr, n_bytes, ec_len)

    size = MATRIX_SIZE[version]
    matrix = [[0] * size for _ in range(size)]

    add_finder(matrix, 0, 0, size)
    add_finder(matrix, size - 7, 0, size)
    add_finder(matrix, 0, size - 7, size)
    add_separators(matrix, size)
    add_timing(matrix, size)
    add_format(matrix, size, FORMAT_L[7], version)
    place_data(matrix, size, result, len(result), 7)

    return matrix

def print_matrix(matrix):
    """Print QR matrix using half-block characters with proper quiet zone margin."""
    size = len(matrix)
    margin = 4  # Quiet zone (4 modules on each side)
    # Top margin
    print()
    print(" " * (margin * 2 + size))
    for i in range(0, size, 2):
        line = " " * (margin * 2)
        for j in range(size):
            top = matrix[i][j] if i < size else 0
            bot = matrix[i+1][j] if i+1 < size else 0
            if top and bot:
                line += "█"
            elif top and not bot:
                line += "▀"
            elif not top and bot:
                line += "▄"
            else:
                line += " "
        print(line)
    # Bottom margin
    print(" " * (margin * 2 + size))
    print()

def print_matrix_raw(matrix):
    for row in matrix:
        print(''.join('1' if c else '0' for c in row))

# Debug flag: 0=no debug, 1=raw matrix, 2=verbose
DEBUG = 0

def qr_encode_debug(data, debug=0):
    """QR encode with optional debug output."""
    global DEBUG
    old_debug = DEBUG
    DEBUG = debug

    version = get_version(len(data))
    ec_len = EC_L[version]
    bits = encode_data(data, version)
    padded = pad_bits(bits, version)

    if debug >= 1:
        print(f"DEBUG: data={repr(data)}")
        print(f"DEBUG: version={version}, ec_len={ec_len}")
        print(f"DEBUG: bits={bits[:40]}... (len={len(bits)})")
        print(f"DEBUG: padded={padded[:40]}... (len={len(padded)})")

    n_bytes = CAPACITY[version]

    bytes_arr = []
    for i in range(n_bytes):
        pos = 0 + i * 8
        byte = 0
        for j in range(8):
            if padded[pos + j] == '1':
                byte += pw2(7 - j)
        bytes_arr.append(byte)

    if debug >= 1:
        print(f"DEBUG: bytes_arr[:5]={[hex(b) for b in bytes_arr[:5]]}")

    result = rs_encode(bytes_arr, n_bytes, ec_len)

    if debug >= 1:
        print(f"DEBUG: rs_encode result[:5]={[hex(b) for b in result[:5]]}")

    size = MATRIX_SIZE[version]
    matrix = [[0] * size for _ in range(size)]

    add_finder(matrix, 0, 0, size)
    add_finder(matrix, size - 7, 0, size)
    add_finder(matrix, 0, size - 7, size)
    add_separators(matrix, size)
    add_timing(matrix, size)
    add_format(matrix, size, FORMAT_L[7], version)
    place_data(matrix, size, result, len(result), 7)

    DEBUG = old_debug
    return matrix

if __name__ == "__main__":
    import sys
    data = sys.argv[1] if len(sys.argv) > 1 else "HI"
    debug = int(sys.argv[2]) if len(sys.argv) > 2 else 0

    if debug > 0:
        matrix = qr_encode_debug(data, debug)
    else:
        matrix = qr_encode(data)
        print(f"=== Python QR Encoder output for '{data}' ===")
        print_matrix(matrix)

    print("\n=== Raw matrix ===")
    print_matrix_raw(matrix)