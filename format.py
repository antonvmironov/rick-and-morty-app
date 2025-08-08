#!/usr/bin/env python3
"""
Script to find and format all Swift files in the repository using swift-format.
Run with: ./format.py
"""
import os
import subprocess
from pathlib import Path

EXCLUDE_DIRS = ['build', '.build']
SWIFT_FORMAT_CMD = 'swift-format'
LINT_ARGS = ['format', '--in-place']

def find_swift_files_step(root_dir):
    import time
    print('🔍\tFinding Swift files...')
    start = time.time()
    swift_files = []
    for dirpath, dirnames, filenames in os.walk(root_dir):
        if any(excluded in Path(dirpath).parts for excluded in EXCLUDE_DIRS):
            continue
        for filename in filenames:
            if filename.endswith('.swift'):
                file_path = Path(dirpath) / filename
                swift_files.append(str(file_path.relative_to(root_dir)))
    elapsed = time.time() - start
    if swift_files:
        print(f'\t✅\tFound {len(swift_files)} Swift files (took {elapsed:.2f} seconds)')
    else:
        print(f'\t⚠️\tNo Swift files found (took {elapsed:.2f} seconds)')
    return swift_files



def format_files_step(swift_files):
    import time
    if not swift_files:
        print('⚠️\tNo Swift files to format.')
        return
    cmd = [SWIFT_FORMAT_CMD] + LINT_ARGS
    mock_command = f'{' '.join(cmd)} <each eligible file>'
    cmd += swift_files
    print('🧹\tFormatting Swift files...')
    print(f'🧹\tRunning: {mock_command}')
    start = time.time()
    result = subprocess.run(cmd, cwd=os.getcwd())
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f'\t❌\tFormatting failed (took {elapsed:.2f} seconds)')
    else:
        print(f'\t✅\tFormatting completed successfully (took {elapsed:.2f} seconds)')



def main():
    import time
    print('🔧\tStarting Swift formatting process...')
    start = time.time()
    repo_root = Path(__file__).parent
    swift_files = find_swift_files_step(repo_root)
    format_files_step(swift_files)
    elapsed = time.time() - start
    print(f'🎉\tAll steps completed! (total time: {elapsed:.2f} seconds)')


if __name__ == '__main__':
    main()
