#!/usr/bin/env bash
# Runs every benchmark suite and drops JSON under benchmark_results/.
#
#   benchmark/tool/run.sh          # from the repo root or anywhere
#
# For trustworthy *timing* numbers run on a quiet machine; the rebuild COUNTS
# are deterministic and fine from `flutter test`. Frame timings need a device
# (see integration_test/).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> parity (fairness gate)"
flutter test test/parity_test.dart

echo "==> model layer"
flutter test test/model_benchmark_test.dart --tags benchmark

echo "==> widget layer — one keystroke"
flutter test test/rebuild_benchmark_test.dart --tags benchmark

echo
echo "JSON written to: benchmark/benchmark_results/"
ls -1 benchmark_results/ 2>/dev/null || true
