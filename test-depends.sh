#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Zerocracy
# SPDX-License-Identifier: MIT

set -euo pipefail
cd "$(dirname "$0")"
expected="$(mktemp)"
trap 'rm -f "$expected"' EXIT
# TeX Live distributes some LaTeX packages together under a different name.
# iexec requires pgfopts, which the CI package installer does not add transitively.
# textcomp ships with the LaTeX base, which the build already requires.
sed -nE 's/^[[:space:]]*\\usepackage(\[[^]]*\])?\{([^}]+)\}.*/\2/p' brand-book.tex |
  tr ',' '\n' |
  while read -r package; do
    case "$package" in
      iexec) printf 'hard pgfopts\n' ;;
      tikz) package=pgf ;;
      graphicx) package=graphics ;;
      multicol) package=tools ;;
      textcomp) continue ;;
    esac
    printf 'hard %s\n' "$package"
  done | sort -u > "$expected"
diff -u "$expected" DEPENDS.txt
echo 'PASS: DEPENDS.txt matches the document packages'
