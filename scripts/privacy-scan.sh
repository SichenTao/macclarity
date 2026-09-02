#!/bin/sh
set -eu
patterns='taosichen|@tohoku\.ac\.jp|terrysc777|/Users/taosichen|gho_[A-Za-z0-9]|github_pat_|BEGIN (RSA|OPENSSH) PRIVATE KEY'
if git grep -nEi "$patterns" -- . ':!scripts/privacy-scan.sh'; then echo "PRIVATE DATA FOUND" >&2; exit 1; fi
echo "PRIVACY VERIFIED"
