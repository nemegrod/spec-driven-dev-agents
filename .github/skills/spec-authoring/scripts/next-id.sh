#!/usr/bin/env bash
# next-id.sh FAMILY   — print the next free ID of a family (FR, NFR, DES, AD, OQ, C, FACT, BUG, G, NG, BL, A, CON, DEBT, D, UX-A ...).
# Numbers are never reused: retired and dropped IDs in docs/, docs/todo/ and docs/done/ count as taken.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"
[ $# -eq 1 ] || { echo "usage: next-id.sh FAMILY" >&2; exit 1; }
fam="$1"
case "$fam" in UX-*) pat="(^|[^0-9A-Za-z-])${fam}[0-9]+" ;; *) pat="(^|[^0-9A-Za-z-])${fam}-[0-9]+" ;; esac
nums="$(grep -rhoE "$pat" docs --include='*.md' | grep -oE '[0-9]+$' || true)"
max="$(printf '%s\n' "$nums" | sort -n | tail -1)"; [ -n "$max" ] || max=0
width="$(printf '%s\n' "$nums" | awk '{ if (length($0) > w) w = length($0) } END { print w + 0 }')"; if [ "$width" -eq 0 ]; then    # first item of a family: the family's conventional width
  case "$fam" in FR|NFR|CON|DES|BUG) width=3 ;; AD|D) width=2 ;; *) width=1 ;; esac
fi
next=$((10#$max + 1))
case "$fam" in UX-*) printf '%s%d\n' "$fam" "$next" ;; *) printf "%s-%0${width}d\n" "$fam" "$next" ;; esac
