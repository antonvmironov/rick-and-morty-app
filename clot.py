#!/usr/bin/env python3
"""
Script to count tokens in a file using tiktoken.
Run with: ./clot.py <filename>
"""
import os
import subprocess
import sys
import tiktoken
import time

def print_usage():
    print("Usage:")
    print("  ./clot.py file <filename>   # Count tokens in a file")
    print("  ./clot.py branch            # Count tokens in current branch diffs")

def count_tokens(file):
    encoding = tiktoken.encoding_for_model("gpt-4")
    with open(file, "r", encoding="utf-8") as f:
        text = f.read()
    tokens = encoding.encode(text)
    return len(tokens)

def should_count_tokens(file):
    allowed_extensions = {"py", "swift", "json", "md"}
    ext = file.rsplit(".", 1)[-1].lower() if "." in file else ""
    return ext in allowed_extensions

def count_for_branch():
    # Get current branch name
    try:
        current_branch = subprocess.check_output([
            "git", "rev-parse", "--abbrev-ref", "HEAD"
        ], encoding="utf-8").strip()
    except Exception as e:
        print(f"❌\tError getting current branch: {e}")
        sys.exit(1)

    if current_branch == "main":
        print("❌\tAlready on 'main' branch. Please checkout a feature branch.")
        sys.exit(1)

    # Get list of changed files since branch diverged from main
    try:
        # Find merge-base
        merge_base = subprocess.check_output([
            "git", "merge-base", "main", current_branch
        ], encoding="utf-8").strip()
        # Get changed files
        changed_files = subprocess.check_output([
            "git", "diff", "--name-only", f"{merge_base}..{current_branch}"
        ], encoding="utf-8").strip().splitlines()
    except Exception as e:
        print(f"❌\tError getting changed files: {e}")
        sys.exit(1)

    print(f"🔀\tCurrent branch: {current_branch}")
    print(f"🔄\tChanged files since diverging from 'main':")
    if changed_files:
        for f in changed_files:
            if should_count_tokens(f):
                count = count_tokens(f)
                print(f"  - {f} - {count} token(s)")
            else:
                pass # file is not interesting
    else:
        print("  (No files changed)")

def main():
    if len(sys.argv) < 2:
        print("❌\tMissing sub-command.")
        print_usage()
        sys.exit(1)

    sub_command = sys.argv[1]
    if sub_command == "file":
        if len(sys.argv) != 3:
            print("❌\tMissing filename argument for 'file' sub-command.")
            print_usage()
            sys.exit(1)
        filename = sys.argv[2]
        if not os.path.exists(filename):
            print(f"❌\tFile not found: {filename}")
            sys.exit(1)
        print(f"📄\tCounting tokens in: {filename}")
        start = time.time()
        try:
            token_count = count_tokens(filename)
            elapsed = time.time() - start
            print(f"🔢\tToken count: {token_count}")
            print(f"✅\tCompleted in {elapsed:.2f} seconds.")
        except Exception as e:
            print(f"❌\tError: {e}")
            sys.exit(1)
    elif sub_command == "branch":
        count_for_branch()
    else:
        print(f"❌\tUnknown sub-command: {sub_command}")
        print_usage()
        sys.exit(1)

if __name__ == "__main__":
    main()
