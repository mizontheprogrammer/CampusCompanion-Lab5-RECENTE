#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/WebPreview"
echo "Campus Companion preview: http://localhost:8000"
python3 -m http.server 8000
