#!/bin/sh
set -eu
swift build
swift test
./scripts/verify-schema.sh
./scripts/verify-budgets.sh
./scripts/privacy-scan.sh
./scripts/verify-launch-assets.sh
./scripts/verify-locales.sh
test -s sbom.spdx.json
swift run macclarity demo --output /tmp/macclarity-demo.html
test -s /tmp/macclarity-demo.html
echo "VERIFIED"
