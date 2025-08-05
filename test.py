#!/usr/bin/env python3
"""
Script to run all tests (or a specific test) for the Rick and Morty app using Tuist.
Run with: ./test.py
Usage:
  ./test.py                # runs all tests
  ./test.py <test_name>    # runs a specific test (e.g. RickAndMortyAppUITests/testDemo)
  ./test.py <test_name> <scheme>  # runs a specific test with a given scheme
"""
import os
import sys
import subprocess
import time
import shutil

DEFAULT_SCHEME = "RickAndMortyApp"
COMPILER_LOG_PATH = "test_compiler.log"
DEFAULT_WORKSPACE = "RickAndMorty.xcworkspace"
DEFAULT_DESTINATION = "platform=iOS Simulator,name=iPhone 16"
TEST_RESULTS_BUNDLE_FILE = "TestResults.xcresult"

def prepare_test_environment():
    # Remove old log and result files before running tests
    if os.path.exists(COMPILER_LOG_PATH):
        os.remove(COMPILER_LOG_PATH)
    if os.path.exists(TEST_RESULTS_BUNDLE_FILE):
        if os.path.isdir(TEST_RESULTS_BUNDLE_FILE):
            shutil.rmtree(TEST_RESULTS_BUNDLE_FILE)
        else:
            os.remove(TEST_RESULTS_BUNDLE_FILE)

def run_all_tests():
    print("🧪\tRunning all tests with xcodebuild...")
    prepare_test_environment()
    cmd = [
        "xcodebuild",
        "test",
        "-workspace", DEFAULT_WORKSPACE,
        "-scheme", DEFAULT_SCHEME,
        "-destination", DEFAULT_DESTINATION,
        "-resultBundlePath", TEST_RESULTS_BUNDLE_FILE
    ]
    print(f"🧪\tRunning: {' '.join(cmd)}")
    start = time.time()
    with open(COMPILER_LOG_PATH, "w") as log_file:
        result = subprocess.run(cmd, cwd=os.getcwd(), stdout=log_file, stderr=subprocess.STDOUT)
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f"\t❌\tTests failed (see {COMPILER_LOG_PATH})")
        sys.exit(result.returncode)
    else:
        print(f"\t✅\tAll tests passed (took {elapsed:.2f} seconds, see {COMPILER_LOG_PATH})")

def run_specific_test(test_name, scheme=DEFAULT_SCHEME):
    print(f"🧪\tRunning specific test: {test_name} (scheme: {scheme}) with xcodebuild")
    prepare_test_environment()
    cmd = [
        "xcodebuild",
        "test",
        "-workspace", DEFAULT_WORKSPACE,
        "-scheme", scheme,
        "-destination", DEFAULT_DESTINATION,
        "-only-testing", test_name,
        "-resultBundlePath", TEST_RESULTS_BUNDLE_FILE
    ]
    print(f"🧪\tRunning: {' '.join(cmd)}")
    start = time.time()
    with open(COMPILER_LOG_PATH, "w") as log_file:
        result = subprocess.run(cmd, cwd=os.getcwd(), stdout=log_file, stderr=subprocess.STDOUT)
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f"\t❌\tTest failed (see {COMPILER_LOG_PATH})")
        sys.exit(result.returncode)
    else:
        print(f"\t✅\tTest passed (took {elapsed:.2f} seconds, see {COMPILER_LOG_PATH})")

def main():
    if len(sys.argv) == 1:
        run_all_tests()
    elif len(sys.argv) == 2:
        run_specific_test(sys.argv[1])
    elif len(sys.argv) == 3:
        run_specific_test(sys.argv[1], scheme=sys.argv[2])
    else:
        print("Usage:\n  ./test.py\n  ./test.py <test_name>\n  ./test.py <test_name> <scheme>")
        sys.exit(1)

if __name__ == "__main__":
    main()
