#!/usr/bin/env python3
"""
QR Code Decoder using OpenCV QRCodeDetector
Tests QR code scannability and compares with reference implementations.
"""

import cv2
import numpy as np
from PIL import Image
import sys
import os

# Add parent directory to path for qrencode
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def create_qr_image(matrix, margin=4, px_per_module=10):
    """Create a PIL Image from QR matrix with quiet zone margin."""
    size = len(matrix)
    img_size = (size + 2 * margin) * px_per_module
    img = Image.new('RGB', (img_size, img_size), 'white')
    pixels = img.load()
    for i in range(size):
        for j in range(size):
            if matrix[i][j]:
                for di in range(px_per_module):
                    for dj in range(px_per_module):
                        pixels[(margin + j) * px_per_module + dj,
                               (margin + i) * px_per_module + di] = (0, 0, 0)
    return img

def decode_qr(image_path):
    """Decode QR code from image file using OpenCV."""
    img = cv2.imread(image_path)
    if img is None:
        return None, None, None

    detector = cv2.QRCodeDetector()
    retval, points, straight_qrcode = detector.detectAndDecode(img)

    return retval, retval, points

def test_qr_scannable(matrix, data, margin=4, px_per_module=10):
    """Test if a QR matrix produces a scannable QR code."""
    img = create_qr_image(matrix, margin, px_per_module)
    tmp_path = '/tmp/test_qr.png'
    img.save(tmp_path)

    retval, decoded_info, points = decode_qr(tmp_path)

    if retval is None or retval == '':
        return False, None, None

    # Handle both string and array return types
    if isinstance(decoded_info, np.ndarray):
        decoded_str = str(decoded_info[0]) if len(decoded_info) > 0 else None
    elif isinstance(decoded_info, bytes):
        decoded_str = decoded_info.decode('utf-8')
    else:
        decoded_str = str(decoded_info)

    matches = decoded_str == data if decoded_str else False
    return matches, decoded_str, points

def compare_matrices(matrix1, matrix2):
    """Compare two QR matrices and return differences."""
    if len(matrix1) != len(matrix2):
        return None, "Matrix sizes differ"

    size = len(matrix1)
    diffs = []
    for i in range(size):
        for j in range(size):
            if matrix1[i][j] != matrix2[i][j]:
                diffs.append((i, j, matrix1[i][j], matrix2[i][j]))

    return diffs, None

def print_matrix_raw(matrix):
    """Print matrix as 0/1 strings."""
    for row in matrix:
        print(''.join('1' if c else '0' for c in row))

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Test QR code scannability with OpenCV')
    parser.add_argument('data', nargs='?', default='aa', help='Data to encode')
    parser.add_argument('--debug', '-d', action='store_true', help='Enable debug output')
    parser.add_argument('--margin', '-m', type=int, default=4, help='Quiet zone margin')
    parser.add_argument('--px', '-p', type=int, default=10, help='Pixels per module')
    args = parser.parse_args()

    # Import qrencode
    try:
        from qrencode import qr_encode
    except ImportError:
        print("Error: qrencode module not found")
        return 1

    data = args.data

    if args.debug:
        print(f"Testing QR scannability for data: {repr(data)}")
        print(f"Settings: margin={args.margin}, px_per_module={args.px}")

    # Generate QR matrix
    matrix = qr_encode(data)

    if args.debug:
        print("\n=== Raw matrix ===")
        print_matrix_raw(matrix)

    # Test scannability
    scannable, decoded, points = test_qr_scannable(matrix, data, args.margin, args.px)

    if scannable:
        print(f"SUCCESS: QR code scannable, decoded data: {repr(decoded)}")
        return 0
    else:
        print(f"FAILED: QR code NOT scannable (decoded: {repr(decoded)})")
        return 1

if __name__ == "__main__":
    sys.exit(main() or 0)
