#!/usr/bin/env python3
"""
universal_header_fix_v4.py
============================

This script attempts to repair the leading bytes of a variety of common
multimedia and image formats after they have been tampered with.  The goal
is to recover files whose header fields (magic numbers or size fields) have
been overwritten but whose bodies remain intact.  Supported file types
include:

* ISO Base Media File Format containers such as MP4/MOV/3GP (ftyp box)
* AVI files (RIFF header)
* FLV files (Flash Video header)
* PNG images (PNG signature)
* JPEG images (SOI marker)

For each supported type the script validates critical header fields against
known specifications, computes the expected values when necessary and, if
`--apply` is supplied on the command line, writes the corrected values back
to the original file.  A timestamped ``.bak`` backup of the original file
is created in the same directory prior to modification.

Usage::

    python3 universal_header_fix_v4.py <file-or-directory> [--apply]

Without ``--apply`` the script performs a dry run, reporting which files
appear corrupted and would be modified.  With ``--apply`` it will perform
the modifications in place.

The code uses information from publicly available specifications to decide
what constitutes a valid header.  For ISO Base Media files, the size of
the ``ftyp`` box is computed as ``16 + 4 * N`` where ``N`` is the number of
``compatible_brand`` entries【366089298693891†L162-L169】【366089298693891†L200-L211】.  For
PNG, JPEG, AVI and FLV the expected magic numbers and flags come from
standard documentation【426017788593307†L371-L377】【546160542124674†L3148-L3152】【753932296085042†L61-L76】 as described
in the accompanying report.
"""

import os
import sys
import struct
import shutil
import logging
from datetime import datetime
from typing import Iterable, Tuple, Optional


###############################################################################
# Logging configuration
###############################################################################

LOGFILE = "header_fix_report_v4.log"
logging.basicConfig(filename=LOGFILE, level=logging.INFO,
                    format='%(asctime)s %(levelname)s: %(message)s')
console = logging.StreamHandler()
console.setLevel(logging.INFO)
logging.getLogger().addHandler(console)


###############################################################################
# File type signatures and helper functions
###############################################################################

VIDEO_EXT_ISOBMFF = {'.mp4', '.mov', '.m4v', '.3gp', '.3g2', '.mj2', '.f4v'}
VIDEO_EXT_AVI     = {'.avi'}
VIDEO_EXT_FLV     = {'.flv'}
IMAGE_EXT_PNG     = {'.png'}
IMAGE_EXT_JPEG    = {'.jpg', '.jpeg'}

# PNG signature bytes (89 50 4E 47 0D 0A 1A 0A)【426017788593307†L371-L377】
PNG_SIGNATURE = b'\x89PNG\r\n\x1a\n'
# JPEG SOI marker (FF D8)【546160542124674†L3148-L3152】
JPEG_SOI = b'\xff\xd8'
# AVI RIFF signature and type code (RIFF AVI )【753932296085042†L61-L76】
AVI_MAGIC = b'RIFF'
AVI_TYPE  = b'AVI '
# FLV header defaults from specification: signature "FLV", version 1,
# flags 0x05 (audio+video) and header length 9 (0x00000009).  These values
# are described in the FLV format documentation which states that the first
# three bytes must read "FLV", the version byte must be 1, the flags byte
# uses bit 0x04 for audio and bit 0x01 for video (0x05 = both audio and
# video), and the header size is 9 bytes【362864803632354†screenshot】.
FLV_SIGNATURE = b'FLV'
FLV_VERSION   = 1
FLV_FLAGS     = 0x05
FLV_HEADER_SIZE = 9

# Reasonable upper bound for a 32-bit size field in ftyp (arbitrary, but far
# larger than typical boxes).  If the current size is above this value it
# is almost certainly corrupted.
MAX_REASONABLE_FTYP_SIZE = 50 * 1024 * 1024  # 50 MB


def read_prefix(path: str, length: int) -> bytes:
    """Read up to `length` bytes from the beginning of `path`.

    Args:
        path: Path to the file.
        length: Number of bytes to read.

    Returns:
        The bytes read (may be fewer than `length` if file is smaller).
    """
    with open(path, 'rb') as f:
        return f.read(length)


def write_bytes(path: str, offset: int, data: bytes) -> None:
    """Write the byte sequence `data` into `path` starting at `offset`.

    Args:
        path: File to modify.
        offset: Position within file to start writing.
        data: Bytes to write.
    """
    with open(path, 'r+b') as f:
        f.seek(offset)
        f.write(data)


def parse_ftyp(data: bytes) -> Tuple[Optional[int], Optional[int], list]:
    """Parse an ISO Base Media 'ftyp' box from a chunk of bytes.

    This helper looks for the ASCII string ``ftyp`` in the data and, if found,
    assumes a valid 4-byte big-endian length field precedes it.  It then reads
    the `major_brand`, `minor_version` and a list of 4-byte
    `compatible_brands` entries.  If the length field is ``1``, the function
    interprets the next 8 bytes as a 64-bit extended size field (largesize).

    Args:
        data: A slice of the file containing at least the first 1024 bytes.

    Returns:
        A tuple ``(size_offset, largesize, brands)`` where:
            size_offset: Offset to the 4-byte size field (int) or None if not
                         found;
            largesize: Value of the 64-bit largesize if present (int) or
                       None otherwise;
            brands: List of ASCII compatible brand strings.
    """
    idx = data.find(b'ftyp')
    if idx < 0:
        return None, None, []
    size_offset = idx - 4
    # Ensure offset is positive and within bounds
    if size_offset < 0 or size_offset + 8 > len(data):
        return None, None, []
    try:
        size_val = struct.unpack('>I', data[size_offset:size_offset + 4])[0]
    except struct.error:
        return None, None, []
    largesize = None
    header_shift = 0
    if size_val == 1:
        # 64-bit largesize follows size and type fields
        if size_offset + 16 <= len(data):
            largesize = struct.unpack('>Q', data[size_offset + 8:size_offset + 16])[0]
            header_shift = 8
    # Now parse brands: 4 bytes major_brand + 4 bytes minor_version followed by brands
    pos = idx + 8 + header_shift  # Skip 'ftyp' + major_brand + minor_version
    brands = []
    # brands may run until end of ftyp box or end of buffer; read until non-ASCII
    while pos + 4 <= len(data):
        chunk = data[pos:pos + 4]
        try:
            s = chunk.decode('ascii')
        except UnicodeDecodeError:
            break
        # Accept only printable ASCII characters
        if all(32 <= ord(c) < 127 for c in s):
            brands.append(s)
            pos += 4
        else:
            break
    return size_offset, largesize, brands


def fix_isobmff(path: str, apply: bool = False) -> bool:
    """Repair the size field of the 'ftyp' box in an ISO Base Media file.

    The function reads the first 8192 bytes of the file to locate the
    ``ftyp`` box, determines the number of ``compatible_brands`` from the
    header, computes the correct size as ``16 + 4*N``, and compares it to
    the current value.  If they differ, and the current value is not a
    64-bit ``largesize`` (size_val == 1), the size field is replaced with
    the computed value.  A backup file ``.bak_YYYYMMDDHHMMSS`` is created
    before modification.  If ``--apply`` is not provided, the function
    reports the discrepancy but does not modify the file.

    Args:
        path: File path to examine.
        apply: If True, perform the modification; otherwise just report.

    Returns:
        True if no repair needed or if repair succeeded, False on error.
    """
    data = read_prefix(path, 8192)
    size_offset, largesize, brands = parse_ftyp(data)
    if size_offset is None:
        logging.info("%s: no ftyp box found", path)
        return False
    # Determine expected size: 16 bytes header + 4 bytes per compatible brand
    expected_size = 16 + 4 * len(brands)
    # Use largesize if present; for our use-case we only fix the 32-bit size
    # field; if largesize exists but does not match expected_size we still
    # attempt to correct the 32-bit field to 1 and write largesize.
    current_size = struct.unpack('>I', data[size_offset:size_offset + 4])[0]
    logging.info(
        "%s: ftyp brands=%s (N=%d) → expected_size=%d, current_size=%d (0x%08X)",
        path, brands, len(brands), expected_size, current_size, current_size
    )
    need_fix = False
    if largesize is None:
        # No largesize present; use 32-bit size field
        if current_size != expected_size:
            need_fix = True
    else:
        # 64-bit largesize present: if mismatched, fix both
        if largesize != expected_size:
            need_fix = True
    # Additional sanity check: extremely large size values are treated as corrupt
    if current_size > MAX_REASONABLE_FTYP_SIZE or current_size == 0:
        need_fix = True
    if not need_fix:
        logging.info("%s: ftyp size field already correct, skipped.", path)
        return True
    if not apply:
        logging.info("%s: DRY-RUN: would write ftyp size %d (0x%08X).", path, expected_size, expected_size)
        return False
    # Make backup
    backup = f"{path}.bak_{datetime.now().strftime('%Y%m%d%H%M%S')}"
    shutil.copy2(path, backup)
    try:
        if largesize is None:
            # Write corrected 32-bit size
            write_bytes(path, size_offset, struct.pack('>I', expected_size))
        else:
            # Write size=1 and 64-bit largesize
            write_bytes(path, size_offset, struct.pack('>I', 1))
            write_bytes(path, size_offset + 8, struct.pack('>Q', expected_size))
        logging.info("%s: ftyp header repaired (size=%d), backup=%s", path, expected_size, backup)
    except Exception as exc:
        logging.error("%s: failed to write ftyp size: %s", path, exc)
        return False
    return True


def fix_avi(path: str, apply: bool = False) -> bool:
    """Repair the header of an AVI file.

    Valid AVI files begin with the RIFF container format.  The first four
    bytes must be ``'RIFF'`` followed by a 32-bit file size (which we do
    not recompute here) and then the type ``'AVI '``【753932296085042†L61-L76】.
    This function checks these magic fields and, if they differ, writes
    the correct values.  The file size field is left untouched; corrupt
    values there may indicate deeper damage.  A backup is created prior
    to modification when ``apply`` is True.

    Args:
        path: Path to the AVI file to inspect.
        apply: If True, modify the file; otherwise just report differences.

    Returns:
        True on success or if no fix needed, False on failure.
    """
    data = read_prefix(path, 12)
    if len(data) < 12:
        logging.info("%s: file too small to contain AVI header", path)
        return False
    riff, size_field, avi_type = data[:4], data[4:8], data[8:12]
    riff_ok = riff == AVI_MAGIC
    avi_ok = avi_type == AVI_TYPE
    logging.info("%s: current RIFF=%s, type=%s", path, riff, avi_type)
    if riff_ok and avi_ok:
        logging.info("%s: AVI header OK.", path)
        return True
    if not apply:
        logging.info("%s: DRY-RUN: would restore AVI header to 'RIFF' ... 'AVI '.", path)
        return False
    backup = f"{path}.bak_{datetime.now().strftime('%Y%m%d%H%M%S')}"
    shutil.copy2(path, backup)
    try:
        if not riff_ok:
            write_bytes(path, 0, AVI_MAGIC)
        # Leave size bytes untouched
        if not avi_ok:
            write_bytes(path, 8, AVI_TYPE)
        logging.info("%s: AVI header repaired, backup=%s", path, backup)
    except Exception as exc:
        logging.error("%s: failed to repair AVI header: %s", path, exc)
        return False
    return True


def fix_flv(path: str, apply: bool = False) -> bool:
    """Repair the header of an FLV (Flash Video) file.

    According to the FLV specification【362864803632354†screenshot】 the header consists of:

    * Signature (3 bytes): Always 'FLV' (0x46 0x4C 0x56)
    * Version (1 byte): Only 0x01 is valid
    * Flags (1 byte): 0x04 for audio, 0x01 for video, so 0x05 means both
    * DataOffset (4 bytes, big-endian): The length of the header in bytes

    This function ensures that the first 3 bytes are 'FLV', the version byte
    equals 1, the flags byte equals 0x05 and the header length equals 9.
    If any field differs, and ``apply`` is True, it rewrites the header with
    these values.  A backup is created beforehand.

    Args:
        path: Path to the FLV file.
        apply: Whether to perform the fix (True) or just report (False).

    Returns:
        True if repair succeeded or not required, False otherwise.
    """
    data = read_prefix(path, 9)
    if len(data) < 9:
        logging.info("%s: file too small to contain FLV header", path)
        return False
    sig, ver, flags, header_len = data[:3], data[3], data[4], data[5:9]
    expected_header_len_bytes = struct.pack('>I', FLV_HEADER_SIZE)
    sig_ok    = sig == FLV_SIGNATURE
    ver_ok    = (ver == FLV_VERSION)
    flags_ok  = (flags == FLV_FLAGS)
    offset_ok = (header_len == expected_header_len_bytes)
    logging.info(
        "%s: FLV header sig=%s, ver=0x%02X, flags=0x%02X, offset=%s",
        path, sig, ver, flags, header_len.hex())
    if sig_ok and ver_ok and flags_ok and offset_ok:
        logging.info("%s: FLV header OK.", path)
        return True
    if not apply:
        logging.info("%s: DRY-RUN: would restore FLV header to 'FLV' version=1 flags=0x05 offset=9.", path)
        return False
    backup = f"{path}.bak_{datetime.now().strftime('%Y%m%d%H%M%S')}"
    shutil.copy2(path, backup)
    try:
        # Compose corrected header
        corrected = FLV_SIGNATURE + bytes([FLV_VERSION, FLV_FLAGS]) + expected_header_len_bytes
        write_bytes(path, 0, corrected)
        logging.info("%s: FLV header repaired, backup=%s", path, backup)
    except Exception as exc:
        logging.error("%s: failed to repair FLV header: %s", path, exc)
        return False
    return True


def fix_png(path: str, apply: bool = False) -> bool:
    """Repair the signature of a PNG file.

    A valid PNG must begin with the eight bytes ``\x89PNG\r\n\x1a\n``【426017788593307†L371-L377】.
    This function verifies those bytes and, if they differ, rewrites them when
    ``apply`` is True.

    Args:
        path: Path to the PNG file.
        apply: Perform the fix if True, else just report.

    Returns:
        True if repaired or already correct, False otherwise.
    """
    data = read_prefix(path, len(PNG_SIGNATURE))
    if data == PNG_SIGNATURE:
        logging.info("%s: PNG signature OK.", path)
        return True
    logging.info("%s: PNG signature mismatch: %s", path, data.hex())
    if not apply:
        logging.info("%s: DRY-RUN: would restore PNG signature.", path)
        return False
    backup = f"{path}.bak_{datetime.now().strftime('%Y%m%d%H%M%S')}"
    shutil.copy2(path, backup)
    write_bytes(path, 0, PNG_SIGNATURE)
    logging.info("%s: PNG signature repaired, backup=%s", path, backup)
    return True


def fix_jpeg(path: str, apply: bool = False) -> bool:
    """Repair the Start Of Image marker of a JPEG file.

    JPEG files must begin with the two bytes ``0xFF 0xD8``【546160542124674†L3148-L3152】.  This function
    verifies these bytes and, if they differ, rewrites them if ``apply`` is
    True.

    Args:
        path: Path to the JPEG file.
        apply: If True, write the SOI marker; else just report.

    Returns:
        True if repaired or already correct, False otherwise.
    """
    data = read_prefix(path, len(JPEG_SOI))
    if data == JPEG_SOI:
        logging.info("%s: JPEG SOI OK.", path)
        return True
    logging.info("%s: JPEG SOI mismatch: %s", path, data.hex())
    if not apply:
        logging.info("%s: DRY-RUN: would restore JPEG SOI.", path)
        return False
    backup = f"{path}.bak_{datetime.now().strftime('%Y%m%d%H%M%S')}"
    shutil.copy2(path, backup)
    write_bytes(path, 0, JPEG_SOI)
    logging.info("%s: JPEG SOI repaired, backup=%s", path, backup)
    return True


def process_file(path: str, apply: bool = False) -> None:
    """Process a single file and apply appropriate header repair.

    Args:
        path: Path to a single file.
        apply: Whether to modify the file in place.
    """
    ext = os.path.splitext(path)[1].lower()
    # Only attempt to open regular files
    if not os.path.isfile(path):
        return
    try:
        if ext in VIDEO_EXT_ISOBMFF:
            fix_isobmff(path, apply)
        elif ext in VIDEO_EXT_AVI:
            fix_avi(path, apply)
        elif ext in VIDEO_EXT_FLV:
            fix_flv(path, apply)
        elif ext in IMAGE_EXT_PNG:
            fix_png(path, apply)
        elif ext in IMAGE_EXT_JPEG:
            fix_jpeg(path, apply)
        else:
            logging.info("%s: Unsupported extension '%s', skipped.", path, ext)
    except Exception as exc:
        logging.error("%s: error processing file: %s", path, exc)


def scan_path(target: str, apply: bool = False) -> None:
    """Recursively scan a file or directory for candidate headers to repair.

    Args:
        target: Path to a file or directory to scan.
        apply: Whether to modify matching files.
    """
    if os.path.isfile(target):
        process_file(target, apply)
    elif os.path.isdir(target):
        for root, dirs, files in os.walk(target):
            for fname in files:
                process_file(os.path.join(root, fname), apply)
    else:
        logging.error("Target not found: %s", target)


def usage() -> None:
    print("Usage: universal_header_fix_v4.py <file_or_directory> [--apply]")


def main(argv: Iterable[str]) -> None:
    if not argv:
        usage()
        return
    target = argv[0]
    apply = False
    if len(argv) > 1 and argv[1] == '--apply':
        apply = True
    logging.info("=== Starting scan on %s (apply=%s) ===", target, apply)
    scan_path(target, apply)
    logging.info("=== Scan complete ===")
    print(f"Done. See report: {LOGFILE}")


if __name__ == '__main__':
    main(sys.argv[1:])