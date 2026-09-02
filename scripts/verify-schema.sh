#!/bin/sh
set -eu
test -s Schemas/diagnostic-snapshot-v1.schema.json
test -s Fixtures/synthetic-stressed-mac-v1.json
python3 -m json.tool Schemas/diagnostic-snapshot-v1.schema.json >/dev/null
python3 -m json.tool Fixtures/synthetic-stressed-mac-v1.json >/dev/null
echo "SCHEMA VERIFIED"
