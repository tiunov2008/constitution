#!/bin/sh
# Checks this repository before a release (CORE-04): every rule ID is defined once, never redefined
# after retirement, and every referenced ID exists; core.md, README.md and CHANGELOG.md state the same
# version. Run from the repository root: sh scripts/check-constitution.sh
set -eu

ids='(CORE|TS|PY|GO|FL|JOBS|DOKPLOY|LLM)-[0-9]+'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

grep -hoE "^### $ids" core.md modules/*.md | sed 's/^### //' | sort > "$tmp/defined"
sed -n '/^## Retired IDs/,/^---/p' core.md | grep -oE "$ids" | sort -u > "$tmp/retired" || true

dups=$(uniq -d "$tmp/defined" | tr '\n' ' ')
if [ -n "$dups" ]; then echo "defined twice: $dups"; fail=1; fi

back=$(sort -u "$tmp/defined" | comm -12 - "$tmp/retired" | tr '\n' ' ')
if [ -n "$back" ]; then echo "retired but defined: $back"; fail=1; fi

# References outside the changelog and the Retired IDs list must point to defined rules.
{
  sed '/^## Retired IDs/,/^---/d' core.md
  cat modules/*.md templates/*.md README.md quickstart.md
} | grep -oE "$ids" | sort -u > "$tmp/referenced"
missing=$(sort -u "$tmp/defined" | comm -13 - "$tmp/referenced" | tr '\n' ' ')
if [ -n "$missing" ]; then echo "referenced but not defined: $missing"; fail=1; fi

core=$(sed -n 's/^\*\*Version\*\*: \([0-9.]*\).*/\1/p' core.md)
readme=$(sed -n 's/^Status: \*\*v\([0-9.]*\)\*\*.*/\1/p' README.md)
log=$(sed -n 's/^## \([0-9][0-9.]*\) .*/\1/p' CHANGELOG.md | head -n 1)
if [ -z "$core" ] || [ "$core" != "$readme" ] || [ "$core" != "$log" ]; then
  echo "versions differ: core.md '$core', README.md '$readme', CHANGELOG.md '$log'"
  fail=1
fi

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "check-constitution: $(wc -l < "$tmp/defined" | tr -d ' ') rules, version $core"
