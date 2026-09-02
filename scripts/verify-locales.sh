#!/bin/sh
set -eu

fail_if_found() {
  pattern="$1"
  shift
  if grep -Ein "$pattern" "$@"; then
    echo "LOCALE CONTAMINATION: $pattern" >&2
    exit 1
  fi
}

fail_if_found '>English<|>Japanese<|>View on|Install from|OPEN SOURCE|LOCAL-FIRST' docs/zh/index.html
fail_if_found '>English<|>Chinese<|>View on|Install from|OPEN SOURCE|LOCAL-FIRST|中文' docs/ja/index.html
fail_if_found '>中文<|>日本語<|从源码|开源|インストール|日本語' docs/en/index.html
for page in docs/en/index.html docs/zh/index.html docs/ja/index.html; do
  grep -q 'id="install"' "$page"
  grep -q './install.sh' "$page"
  grep -q 'diagnosis-flow.svg' "$page"
done
echo "LOCALES VERIFIED"
