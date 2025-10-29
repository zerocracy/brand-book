# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

.SHELLFLAGS=-e -o pipefail -c
.ONESHELL:
SHELL=bash
.PHONY: all test clean

all: brand-book.pdf zip

brand-book.pdf: brand-book.tex
	latexmk -pdf -latexoption=-interaction=errorstopmode -latexoption=-halt-on-error $<

clean:
	git clean -dfX
