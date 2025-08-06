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

def create_venv_step():
    venv_python = Path('.venv/bin/python')
    if not venv_python.exists():
        _run_install_step(
            name='Create Python virtual environment',
            emoji='🧪',
            cmd=['python3', '-m', 'venv', '.venv']
        )
    else:
        print('\t✅\tVirtual environment already exists at .venv/bin/python')

def pip_install_requirements_step():
    venv_python = Path('.venv/bin/python')
    if venv_python.exists():
        _run_install_step(
            name='Activate venv and install Python dependencies',
            emoji='🐍',
            cmd=[str(venv_python), '-m', 'pip', 'install', '-r', 'requirements.txt']
        )
    else:
        print('\t❌\tVirtual environment not found at .venv/bin/python')
        exit(1)

def tuist_install_step():
    _run_install_step(name='Install Tuist', emoji='🚀', cmd=['tuist', 'install'])

def main():
    import time
    print("🔧\tStarting installation process...")
    start = time.time()
    brew_bundle_step()
    create_venv_step()
    pip_install_requirements_step()
    tuist_install_step()
    elapsed = time.time() - start
    print(f"🎉\tAll steps completed successfully! (total time: {elapsed:.2f} seconds)")

if __name__ == '__main__':
    main()
