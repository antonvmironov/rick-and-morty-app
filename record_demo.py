#!/usr/bin/env python3
"""
Script to record a demo video of the Rick and Morty app UI test using Xcode Simulator.
Run with: ./record_demo.py
"""
import os
import subprocess
import signal
import time
from pathlib import Path
import json

SCHEME = "RickAndMortyApp"
SIMULATOR_NAME = "iPhone 16"
PLATFORM = "platform=iOS Simulator"
DESTINATION = f"{PLATFORM},name={SIMULATOR_NAME}"
WORKSPACE = "RickAndMorty.xcworkspace"
TEST_TARGET = "RickAndMortyAppUITests"
TEST_NAME = "RickAndMortyAppUITests/testDemo"
RAW_VIDEO_PATH = "record_demo_raw_video.mp4"
FINAL_VIDEO_PATH = "record_demo_final_video.mp4"
LOG_PATH = "record_demo_compiler.log"
SIMCTL = "xcrun simctl"
XCODEBUILD = "xcodebuild"

def _run_step(name, emoji, cmd, check=True):
    print(f"{emoji}\t{name}")
    print(f"{emoji}\tRunning: {' '.join(cmd)}")
    start = time.time()
    result = subprocess.run(cmd, cwd=os.getcwd(), check=check)
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f"\t❌\tStep failed: {name}")
        exit(result.returncode)
    else:
        print(f"\t✅\tStep completed: {name} (took {elapsed:.2f} seconds)")
    return result

def boot_simulator_step():
    # Check if the simulator is already booted
    result = subprocess.run([
        *SIMCTL.split(), "list", "devices", "--json"
    ], capture_output=True, text=True)
    import json
    devices = json.loads(result.stdout)["devices"]
    booted = False
    for runtime in devices:
        for device in devices[runtime]:
            if device["name"] == SIMULATOR_NAME and device["state"] == "Booted":
                booted = True
                break
        if booted:
            break
    if booted:
        print(f"📱\tSimulator '{SIMULATOR_NAME}' is already booted. Skipping boot step.")
    else:
        _run_step(
            name="Boot iOS Simulator",
            emoji="📱",
            cmd=[*SIMCTL.split(), "boot", SIMULATOR_NAME],
            check=False
        )

def start_recording_step():
    print("🎥\tStarting screen recording...")
    start = time.time()
    proc = subprocess.Popen([*SIMCTL.split(), "io", "booted", "recordVideo", RAW_VIDEO_PATH])
    time.sleep(1)  # Ensure recording starts
    elapsed = time.time() - start
    print(f"\t✅\tScreen recording started (took {elapsed:.2f} seconds)")
    return proc

def run_ui_test_step():
    # Redirect xcodebuild output to record_demo_compiler.log
    log_file = open(LOG_PATH, "w")
    print(f"🧪\tRun UI Test (output redirected to {LOG_PATH})")
    cmd = [
        XCODEBUILD,
        "test",
        "-workspace", WORKSPACE,
        "-scheme", SCHEME,
        "-destination", DESTINATION,
        "-only-testing:" + f"{TEST_TARGET}/{TEST_NAME}"
    ]
    start = time.time()
    result = subprocess.run(cmd, cwd=os.getcwd(), stdout=log_file, stderr=subprocess.STDOUT)
    elapsed = time.time() - start
    log_file.close()
    if result.returncode != 0:
        print(f"\t❌\tStep failed: Run UI Test (see {LOG_PATH})")
        exit(result.returncode)
    else:
        print(f"\t✅\tStep completed: Run UI Test (took {elapsed:.2f} seconds, see {LOG_PATH})")

def stop_recording_step(proc):
    print("🛑\tStopping screen recording...")
    start = time.time()
    proc.send_signal(signal.SIGINT)  # simulates Ctrl+C
    proc.wait()
    elapsed = time.time() - start
    print(f"\t✅\tScreen recording stopped (took {elapsed:.2f} seconds)")

def convert_and_trim_video_step():
    print("🎬\tConverting and trimming video with ffmpeg...")
    # Get video duration
    probe_cmd = [
        "ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "json", RAW_VIDEO_PATH
    ]
    probe_result = subprocess.run(probe_cmd, capture_output=True, text=True)
    duration = None
    try:
        duration = float(json.loads(probe_result.stdout)["format"]["duration"])
    except Exception as e:
        print(f"⚠️\tCould not get video duration: {e}")
    if duration is None or duration < 8:
        print(f"⚠️\tVideo duration too short to trim. Skipping trim.")
        trim_args = []
    else:
        # Trim first 7 seconds and last 1 second
        start_trim = 7
        end_trim = duration - 1 - start_trim
        trim_args = ["-ss", str(start_trim), "-t", str(end_trim)]
    ffmpeg_cmd = [
        "ffmpeg",
        "-y",
        *trim_args,
        "-i", RAW_VIDEO_PATH,
        "-an",  # Remove audio
        "-vf", "scale=-2:1024",
        "-c:v", "libx264",  # Explicitly use H.264
        "-preset", "fast",
        "-crf", "23",
        FINAL_VIDEO_PATH
    ]
    print(f"🎬\tRunning: {' '.join(ffmpeg_cmd)}")
    start = time.time()
    result = subprocess.run(ffmpeg_cmd)
    elapsed = time.time() - start
    if result.returncode != 0:
        print(f"\t❌\tStep failed: ffmpeg convert/trim")
        exit(result.returncode)
    else:
        print(f"\t✅\tStep completed: ffmpeg convert/trim (took {elapsed:.2f} seconds)")

def main():
    # Cleanup previous outputs
    for path in [RAW_VIDEO_PATH, FINAL_VIDEO_PATH, LOG_PATH]:
        if os.path.exists(path):
            try:
                os.remove(path)
                print(f"🧹\tRemoved previous output: {path}")
            except Exception as e:
                print(f"⚠️\tCould not remove {path}: {e}")
    print("🔧\tStarting demo recording process...")
    start = time.time()
    boot_simulator_step()
    recorder = start_recording_step()
    try:
        run_ui_test_step()
    except subprocess.CalledProcessError as e:
        print(f"❌\tUI Test failed: {e}")
    finally:
        stop_recording_step(recorder)
    convert_and_trim_video_step()
    elapsed = time.time() - start
    print(f"🎉\tDemo recording completed! Video saved to {RAW_VIDEO_PATH} (total time: {elapsed:.2f} seconds)")

if __name__ == "__main__":
    main()
