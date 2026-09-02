#!/bin/sh
set -eu
for f in docs/assets/hero.svg docs/assets/diagnosis-flow.svg docs/en/index.html docs/zh/index.html docs/ja/index.html README.md README.zh-CN.md README.ja.md; do test -s "$f"; done
test -x install.sh
./scripts/privacy-scan.sh
for f in README.md README.zh-CN.md README.ja.md; do grep -q 'docs/assets/hero.svg' "$f"; done
echo "LAUNCH ASSETS VERIFIED"
