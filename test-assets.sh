#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Zerocracy
# SPDX-License-Identifier: MIT
set -euo pipefail

root=$(cd "$(dirname "$0")" && pwd)
fixture=$(mktemp -d)
trap 'rm -rf "${fixture}"' EXIT
cp "${root}/Makefile" "${fixture}/Makefile"
mkdir "${fixture}/bin"
cat > "${fixture}/bin/wget" <<'WGET'
#!/usr/bin/env bash
set -euo pipefail
output=''
while [ "$#" -gt 0 ]; do
    case "$1" in
        -O) output=$2; shift 2 ;;
        --quiet) shift ;;
        https://*) url=$1; shift ;;
        *) exit 2 ;;
    esac
done
asset=${url##*/}
printf '%s\n' "${asset}" >> downloads.txt
if [ "${FAIL_DOWNLOAD:-}" = "${asset}" ]; then
    printf 'partial download' > "${output}"
    exit 8
fi
case "${asset}" in
    logo.svg|palette.css) cp "${REMOTE}/${asset}" "${output}" ;;
    molot-regular.ttf) printf 'test font' > "${output}" ;;
    *) exit 2 ;;
esac
WGET
cat > "${fixture}/bin/latexmk" <<'LATEXMK'
#!/usr/bin/env bash
set -euo pipefail
source=${!#}
printf '%s\n' "${source}" >> builds.txt
cat logo.svg palette.tex > "${source%.tex}.pdf"
LATEXMK
chmod +x "${fixture}/bin/wget" "${fixture}/bin/latexmk"
export PATH="${fixture}/bin:${PATH}"
export REMOTE="${fixture}/remote"
mkdir "${REMOTE}"
cd "${fixture}"
pdfs=(brand-book.pdf)
touch molot-regular.ttf
touch -t 200001010000 .latexmkrc

check_pdfs() {
    cat logo.svg palette.tex > expected.pdf
    for pdf in "${pdfs[@]}"; do
        cmp expected.pdf "${pdf}"
    done
}

printf 'old logo' > logo.svg
printf '.steel{color:#010203}\n' > palette.css
printf '\\definecolor{steel}{HTML}{010203}\n' > palette.tex
touch -t 200001010000 logo.svg palette.css palette.tex molot-regular.ttf Makefile
for pdf in "${pdfs[@]}"; do
    touch -t 200001010000 "${pdf%.pdf}.tex"
    printf 'old PDF' > "${pdf}"
    touch -t 200001010001 "${pdf}"
done
printf 'first remote logo' > "${REMOTE}/logo.svg"
printf '.steel{color:#A1b2C3}\n.red{color:#112233}\n' > "${REMOTE}/palette.css"
make --no-print-directory -j2 all
cmp "${REMOTE}/logo.svg" logo.svg
printf '\\definecolor{steel}{HTML}{A1b2C3}\n\\definecolor{red}{HTML}{112233}\n' > expected.tex
cmp expected.tex palette.tex
check_pdfs
test "$(wc -l < builds.txt)" -eq "${#pdfs[@]}"
test "$(grep -c '^logo.svg$' downloads.txt)" -eq 1
test "$(grep -c '^palette.css$' downloads.txt)" -eq 1

for asset in logo.svg palette.css palette.tex; do
    touch -r "${asset}" "${asset}.timestamp"
done
make --no-print-directory all
for asset in logo.svg palette.css palette.tex; do
    test ! "${asset}" -nt "${asset}.timestamp"
    test ! "${asset}.timestamp" -nt "${asset}"
done
test "$(wc -l < builds.txt)" -eq "${#pdfs[@]}"

printf '.steel{color:#445566}\n' > "${REMOTE}/palette.css"
make --no-print-directory all
printf '\\definecolor{steel}{HTML}{445566}\n' > expected.tex
cmp expected.tex palette.tex
check_pdfs
test "$(wc -l < builds.txt)" -eq "$((2 * ${#pdfs[@]}))"
printf 'updated remote logo' > "${REMOTE}/logo.svg"
make --no-print-directory all
check_pdfs
test "$(wc -l < builds.txt)" -eq "$((3 * ${#pdfs[@]}))"

for asset in logo.svg palette.css; do
    if FAIL_DOWNLOAD=${asset} make --no-print-directory all; then
        echo "A failed ${asset} download must fail the build" >&2
        exit 1
    fi
    cmp "${REMOTE}/${asset}" "${asset}"
    check_pdfs
    test "$(wc -l < builds.txt)" -eq "$((3 * ${#pdfs[@]}))"
    test -z "$(find . -name "${asset}.??????" -print)"
done

printf 'invalid palette' > "${REMOTE}/palette.css"
if make --no-print-directory all; then
    echo 'A palette without color definitions must fail the build' >&2
    exit 1
fi
cmp expected.tex palette.tex
check_pdfs
test "$(wc -l < builds.txt)" -eq "$((3 * ${#pdfs[@]}))"
test -z "$(find . -name 'palette.tex.??????' -print)"

printf '.steel{color:#445566}\n' > "${REMOTE}/palette.css"
rm logo.svg palette.css palette.tex molot-regular.ttf
make --no-print-directory molot-regular.ttf logo.svg palette.tex
cmp "${REMOTE}/logo.svg" logo.svg
cmp expected.tex palette.tex
test -s molot-regular.ttf
test "$(wc -l < builds.txt)" -eq "$((3 * ${#pdfs[@]}))"
echo 'PASS: remote assets refresh, unchanged content skips rebuild, failures preserve generated output, CI assets prepare without LaTeX'
