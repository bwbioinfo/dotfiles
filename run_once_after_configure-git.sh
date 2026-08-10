#!/usr/bin/env bash
set -euo pipefail

source_dir="${CHEZMOI_SOURCE_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)}"
"$source_dir/scripts/configure-git.sh"
