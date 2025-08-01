#!/usr/bin/env python3
"""
Script to set up the development environment by installing dependencies with Homebrew and Tuist.
Run with: ./install.py
"""
import os
import subprocess
from pathlib import Path

def _run_install_step(*, name, emoji, cmd):
    import time
    print(f"{emoji}\t{name}")
    print(f"{emoji}\tRunning: {' '.join(cmd)}")
    start = time.time()
    result = subprocess.run(cmd, cwd=os.getcwd())
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f"\t❌\tStep failed: {name}")
        exit(result.returncode)
    else:
        print(f"\t✅\tStep completed: {name} (took {elapsed:.2f} seconds)")

def brew_bundle_step():
    _run_install_step(name='Install dependencies with Homebrew', emoji='🍺', cmd=['brew', 'bundle'])

def tuist_install_step():
    _run_install_step(name='Install Tuist', emoji='🚀', cmd=['tuist', 'install'])

def main():
    import time
    print("🔧\tStarting installation process...")
    start = time.time()
    brew_bundle_step()
    tuist_install_step()
    elapsed = time.time() - start
    print(f"🎉\tAll steps completed successfully! (total time: {elapsed:.2f} seconds)")

if __name__ == '__main__':
    main()
