#!/usr/bin/env python3
"""
Script to generate the Xcode project using Tuist.
Run with: ./generate.py
"""
import os
import subprocess
from pathlib import Path
import time

def tuist_generate_step():
    print('⚡\tGenerate project with Tuist')
    cmd = ['tuist', 'generate']
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
    print('🔧\tStarting project generation process...')
    start = time.time()
    tuist_generate_step()
    elapsed = time.time() - start
    print(f'🎉\tAll steps completed successfully! (total time: {elapsed:.2f} seconds)')

if __name__ == '__main__':
    main()
