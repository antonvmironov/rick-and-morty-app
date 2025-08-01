#!/bin/bash
# Normalize git line endings and check for changes
set -e

cd subject
git add --renormalize .
git diff --exit-code
