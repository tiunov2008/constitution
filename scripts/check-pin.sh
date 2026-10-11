#!/bin/sh
# Checks that the constitution submodule is at the version the project's entry file pins (CORE-05).
# Run from the project root: sh .specify/constitution/scripts/check-pin.sh [entry file]
# The entry file states a release tag (vX.Y.Z) or a full commit SHA. CI checkouts are shallow and have
# no tags, so the one tag needed is fetched.
set -eu

entry=${1:-.specify/memory/constitution.md}
sub=.specify/constitution

if [ ! -f "$sub/core.md" ]; then
  echo "check-pin: $sub is empty; run git submodule update --init" >&2
  exit 1
fi

pin=$(sed -n 's/.*pinned at \*\*\([^*]*\)\*\*.*/\1/p' "$entry" | head -n 1)
if [ -z "$pin" ]; then
  echo "check-pin: no 'pinned at **...**' in $entry" >&2
  exit 1
fi

case "$pin" in
  v*)
    git -C "$sub" fetch --quiet --depth=1 origin "refs/tags/$pin:refs/tags/$pin" 2>/dev/null || true
    want=$(git -C "$sub" rev-parse --verify --quiet "$pin^{commit}") || {
      echo "check-pin: tag $pin not found in $sub" >&2
      exit 1
    }
    ;;
  *) want=$pin ;;
esac

have=$(git -C "$sub" rev-parse HEAD)
if [ "$have" != "$want" ]; then
  echo "check-pin: $sub is at $have, but $entry pins $pin ($want)" >&2
  exit 1
fi
echo "check-pin: $sub matches $pin"
