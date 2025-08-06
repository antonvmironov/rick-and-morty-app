#!/usr/bin/env python3
"""
Script to count tokens in a file using tiktoken.
Run with: ./clot.py <filename>
"""
import os
import sys
import tiktoken
import time

def print_usage():
    print("Usage:\n  ./clot.py <filename>")

def main():
    if len(sys.argv) != 2:
        print("❌\tMissing filename argument.")
        print_usage()
        sys.exit(1)

    filename = sys.argv[1]
    if not os.path.exists(filename):
        print(f"❌\tFile not found: {filename}")
        sys.exit(1)

    print(f"📄\tCounting tokens in: {filename}")
    start = time.time()
    try:
        encoding = tiktoken.encoding_for_model("gpt-4")
        with open(filename, "r", encoding="utf-8") as f:
            text = f.read()
        tokens = encoding.encode(text)
        elapsed = time.time() - start
        print(f"🔢\tToken count: {len(tokens)}")
        print(f"✅\tCompleted in {elapsed:.2f} seconds.")
    except Exception as e:
        print(f"❌\tError: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
