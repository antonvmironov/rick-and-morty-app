#!/bin/bash
# Run Swift format check and fail if formatting is not correct
set -e

cd subject
./format.py
git diff --exit-code
