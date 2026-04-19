# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Zerocracy
# SPDX-License-Identifier: MIT

.SHELLFLAGS=-e -o pipefail -c
.ONESHELL:
SHELL=bash
.PHONY: all test clean

all: brand-book.pdf

cambria-regular.ttf:
	wget -O $@ https://www.yegor256.com/fonts/cambria/$@
candara-regular.ttf:
	wget -O $@ https://www.yegor256.com/fonts/candara/$@
consolas-regular.ttf:
	wget -O $@ https://www.yegor256.com/fonts/consolas/$@
molot-regular.ttf:
	wget -O $@ https://www.yegor256.com/fonts/molot/$@

brand-book.pdf: brand-book.tex cambria-regular.ttf candara-regular.ttf consolas-regular.ttf molot-regular.ttf
	latexmk -pdf -latexoption=-interaction=errorstopmode -latexoption=-halt-on-error $<

clean:
	git clean -dfX
