#!/bin/sh
set -eu
version="${1:-0.1.0}"
swift build -c release --product macclarity
mkdir -p release
cp .build/release/macclarity release/macclarity
tar -czf "release/macclarity-${version}-macos-arm64.tar.gz" -C release macclarity
shasum -a 256 "release/macclarity-${version}-macos-arm64.tar.gz" > "release/checksums.txt"
if security find-identity -v -p codesigning | grep -q 'Developer ID Application'; then codesign --force --options runtime --timestamp --sign "Developer ID Application" release/macclarity; else echo "UNSIGNED: no Developer ID Application identity" > release/signing-status.txt; fi
echo "RELEASE CANDIDATE BUILT"
