# Brand Book of Zerocracy

[![make](https://github.com/zerocracy/brand-book/actions/workflows/latexmk.yml/badge.svg)](https://github.com/zerocracy/brand-book/actions/workflows/latexmk.yml)

This is the
[PDF](https://zerocracy.github.io/brand-book/brand-book.pdf).

To build it, just run:

```bash
make
```

You need to have
[`latexmk`](https://ctan.org/pkg/latexmk),
[`inkscape`](https://inkscape.org/),
[`wget`](https://www.gnu.org/software/wget/),
LaTeX (TeX Live with `xelatex`),
and the fonts
[PT Serif](https://fonts.google.com/specimen/PT+Serif),
[PT Sans](https://fonts.google.com/specimen/PT+Sans),
[PT Mono](https://fonts.google.com/specimen/PT+Mono)
installed.

To run source code quality checks (spelling, style, formatting), use:

```bash
make test
```

This additionally requires
[`aspell`](http://aspell.net/),
Ruby, and the
[`texsc`](https://rubygems.org/gems/texsc)
and
[`texqc`](https://rubygems.org/gems/texqc) gems.
