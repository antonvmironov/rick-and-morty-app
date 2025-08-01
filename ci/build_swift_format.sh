#!/bin/bash
# Build swift-format from source and copy the binary to swift-format-bin
set -e

git clone --depth 1 --branch swift-6.1.1-RELEASE https://github.com/apple/swift-format.git
cd swift-format
swift build -c release
mkdir -p ../swift-format-bin
BIN_PATH=$(swift build --show-bin-path -c release)
cp "$BIN_PATH"/swift-format  ../swift-format-bin/swift-format
