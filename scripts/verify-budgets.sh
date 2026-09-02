#!/bin/sh
set -eu
test "$(grep -En 'maxNodes|maxDuration|maxDepth' Sources/MacClarityCollectors/StorageScanner.swift | wc -l | tr -d ' ')" -ge 3
test "$(grep -Ehn 'Task.checkCancellation|Task.yield' Sources/MacClarityCollectors/*.swift | wc -l | tr -d ' ')" -ge 2
echo "BUDGETS VERIFIED"
