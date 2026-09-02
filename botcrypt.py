#!/usr/bin/env python3
"""
botcrypt.py - Encrypt/decrypt the bot source code (bot.enc).

Output format is 100% compatible with:
    openssl enc -aes-256-cbc -pbkdf2 -pass env:CODE_KEY
so GitHub Actions can decrypt it at runtime.

Usage:
    python botcrypt.py encrypt                    # jm1.8.0_3.py -> bot.enc
    python botcrypt.py decrypt [in] [out]         # bot.enc -> file
Password comes from CODE_KEY env var or STATE_KEY.local.txt file.
"""
import hashlib
import os
import sys

from cryptography.hazmat.primitives import padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

ITERATIONS = 10000  # must match openssl 3.x pbkdf2 default


def _derive(password: bytes, salt: bytes):
    """Derive 32-byte AES key + 16-byte IV (same as openssl pbkdf2)."""
    dk = hashlib.pbkdf2_hmac("sha256", password, salt, ITERATIONS, dklen=48)
    return dk[:32], dk[32:]


def encrypt(src: str, dst: str, password: bytes):
    salt = os.urandom(8)
    key, iv = _derive(password, salt)
    padder = padding.PKCS7(128).padder()
    data = padder.update(open(src, "rb").read()) + padder.finalize()
    enc = Cipher(algorithms.AES(key), modes.CBC(iv)).encryptor()
    ct = enc.update(data) + enc.finalize()
    with open(dst, "wb") as f:
        f.write(b"Salted__" + salt + ct)
    print(f"[OK] Encrypted: {src} -> {dst} ({len(ct)} bytes)")


def decrypt(src: str, dst: str, password: bytes):
    raw = open(src, "rb").read()
    if raw[:8] != b"Salted__":
        raise ValueError("Wrong key or not an openssl-encrypted file!")
    key, iv = _derive(password, raw[8:16])
    dec = Cipher(algorithms.AES(key), modes.CBC(iv)).decryptor()
    data = dec.update(raw[16:]) + dec.finalize()
    unpadder = padding.PKCS7(128).unpadder()
    with open(dst, "wb") as f:
        f.write(unpadder.update(data) + unpadder.finalize())
    print(f"[OK] Decrypted: {src} -> {dst}")


def get_password() -> bytes:
    env = os.environ.get("CODE_KEY")
    if env:
        return env.strip().encode()
    if os.path.exists("STATE_KEY.local.txt"):
        return open("STATE_KEY.local.txt", encoding="utf-8").read().strip().encode()
    sys.exit("[ERROR] No key found! Set CODE_KEY env var or create STATE_KEY.local.txt")


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in ("encrypt", "decrypt"):
        print(__doc__)
        sys.exit(1)
    pw = get_password()
    if sys.argv[1] == "encrypt":
        encrypt("jm1.8.0_3.py", "bot.enc", pw)
    else:
        src = sys.argv[2] if len(sys.argv) > 2 else "bot.enc"
        dst = sys.argv[3] if len(sys.argv) > 3 else "jm_decrypted_test.py"
        decrypt(src, dst, pw)
