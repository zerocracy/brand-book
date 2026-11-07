#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Zerocracy
# SPDX-License-Identifier: MIT

set -euo pipefail
makefile="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir "$scratch/bin" "$scratch/build"
cat > "$scratch/bin/wget" <<'WGET'
#!/usr/bin/env bash
set -euo pipefail
test "$1" = '-O'
printf 'partial-font' > "$2"
if test "${FAIL_DOWNLOAD:-0}" = 1; then
  exit 4
fi
printf 'complete-font' > "$2"
WGET
chmod +x "$scratch/bin/wget"
export PATH="$scratch/bin:$PATH"
if FAIL_DOWNLOAD=1 make --no-print-directory -f "$makefile" -C "$scratch/build" molot-regular.ttf; then
  echo 'FAIL: a failed download unexpectedly succeeded' >&2
  exit 1
fi
if test -e "$scratch/build/molot-regular.ttf"; then
  echo 'FAIL: a failed download left a corrupt target; make will skip retry' >&2
  exit 1
fi
make --no-print-directory -f "$makefile" -C "$scratch/build" molot-regular.ttf
test "$(cat "$scratch/build/molot-regular.ttf")" = 'complete-font'
shopt -s nullglob dotglob
files=("$scratch/build"/*)
test "${#files[@]}" -eq 1
echo 'PASS: failed download cleaned up, successful retry installed complete font'
