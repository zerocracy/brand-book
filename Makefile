# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Zerocracy
# SPDX-License-Identifier: MIT

.SHELLFLAGS=-e -o pipefail -c
.ONESHELL:
SHELL=bash
.PHONY: all test test-download test-assets clean FORCE

all: brand-book.pdf

test: test-download test-assets brand-book.pdf
	texsc brand-book.tex
	texqc brand-book

test-assets:
	bash test-assets.sh

test-download:
	bash test-font-download.sh Makefile

molot-regular.ttf:
	tmp=$$(mktemp "$@.XXXXXX")
	trap 'rm -f "$$tmp"' EXIT
	wget -O "$$tmp" https://www.yegor256.com/fonts/molot/$@
	mv "$$tmp" "$@"

logo.svg: FORCE
	temp=$$(mktemp "$@.XXXXXX")
	trap 'rm -f "$${temp}"' EXIT
	wget --quiet -O "$${temp}" https://www.zerocracy.com/svg/logo.svg
	if ! cmp -s "$${temp}" "$@"; then
		mv "$${temp}" "$@"
	fi

palette.css: FORCE
	temp=$$(mktemp "$@.XXXXXX")
	trap 'rm -f "$${temp}"' EXIT
	wget --quiet -O "$${temp}" https://www.zerocracy.com/css/palette.css
	if ! cmp -s "$${temp}" "$@"; then
		mv "$${temp}" "$@"
	fi

palette.tex: palette.css Makefile
	temp=$$(mktemp "$@.XXXXXX")
	trap 'rm -f "$${temp}"' EXIT
	grep -oE '\.[a-zA-Z0-9_-]+\{color:.[0-9a-fA-F]+' < "$<" | sed -E 's/\.([a-zA-Z0-9_-]+)\{color:.([0-9a-fA-F]+)/\\definecolor{\1}{HTML}{\2}/' > "$${temp}"
	if ! cmp -s "$${temp}" "$@"; then
		mv "$${temp}" "$@"
	fi

brand-book.pdf: brand-book.tex molot-regular.ttf .latexmkrc logo.svg palette.tex
	latexmk -pdf -latexoption=-interaction=nonstopmode -latexoption=-halt-on-error $<

FORCE:

clean:
	git clean -dfX
