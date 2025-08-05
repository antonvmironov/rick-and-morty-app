#!/usr/bin/env python3
"""
Script to generate the Xcode project using Tuist.
Run with: ./generate.py
"""
import argparse
import os
import subprocess
import time
from pathlib import Path

def tuist_generate_step(no_xcode=False):
    print('⚡\tGenerate project with Tuist')
    cmd = ['tuist', 'generate']
    if no_xcode:
        cmd.append('--no-open')
    print('⚡\tRunning:', ' '.join(cmd))
    start = time.time()
    result = subprocess.run(cmd, cwd=os.getcwd())
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f'\t❌\tStep failed: Tuist generate')
        exit(result.returncode)
    else:
        print(f'\t✅\tStep completed: Tuist generate (took {elapsed:.2f} seconds)')

def main():
    parser = argparse.ArgumentParser(description='Generate Xcode project using Tuist.')
    parser.add_argument('--no-xcode', action='store_true', help='Do not launch Xcode after generating the project.')
    args = parser.parse_args()

    print('🔧\tStarting project generation process...')
    start = time.time()
    tuist_generate_step(no_xcode=args.no_xcode)
    elapsed = time.time() - start
    print(f'🎉\tAll steps completed successfully! (total time: {elapsed:.2f} seconds)')

if __name__ == '__main__':
    main()
