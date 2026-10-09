#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v uv >/dev/null; then curl -LsSf https://astral.sh/uv/install.sh | sh; fi
export PATH="$HOME/.local/bin:$PATH"
uv sync
printf '\nRun: make doctor && make test && make test-docker\n'
