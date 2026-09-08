#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <reference.png> <candidate.png> <diff.png>" >&2
  exit 2
fi

if ! command -v compare >/dev/null 2>&1; then
  echo "ImageMagick is required (install the 'imagemagick' package)." >&2
  exit 1
fi

set +e
compare -metric AE "$1" "$2" "$3" 2>"$3.metric"
status=$?
set -e
echo "Diff written to $3 (pixel count is in $3.metric)."
if [[ $status -gt 1 ]]; then
  exit "$status"
fi
