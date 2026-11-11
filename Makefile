# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Zerocracy
# SPDX-License-Identifier: MIT

.SHELLFLAGS=-e -o pipefail -c
.ONESHELL:
SHELL=bash
.PHONY: all test test-download clean

all: brand-book.pdf

test: test-download brand-book.pdf
	texsc brand-book.tex
	texqc brand-book

test-download:
	bash test-font-download.sh Makefile

molot-regular.ttf:
	tmp=$$(mktemp "$@.XXXXXX")
	trap 'rm -f "$$tmp"' EXIT
	wget -O "$$tmp" https://www.yegor256.com/fonts/molot/$@
	mv "$$tmp" "$@"

brand-book.pdf: brand-book.tex molot-regular.ttf .latexmkrc
	latexmk -pdf -latexoption=-interaction=nonstopmode -latexoption=-halt-on-error $<

clean:
	git clean -dfX
