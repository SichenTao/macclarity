#!/bin/sh
set -eu

install_dir="${MACCLARITY_INSTALL_DIR:-$HOME/.local/bin}"
swift build -c release --product macclarity
mkdir -p "$install_dir"
install -m 0755 .build/release/macclarity "$install_dir/macclarity"
printf 'Installed MacClarity to %s\n' "$install_dir/macclarity"
case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) printf 'Add %s to PATH to run macclarity from any terminal.\n' "$install_dir" ;;
esac
