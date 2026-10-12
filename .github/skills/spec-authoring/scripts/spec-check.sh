#!/usr/bin/env bash
# spec-check.sh — lint the specification set. Exit 0 when clean, 1 with a list of findings.
#
#   1. The core register and index files exist (optional registers are checked when present).
#   2. Every ID is defined exactly once, in the file its family belongs to.
#   3. Every ID cited in docs/*.md, docs/lld/*.md and docs/todo/**/*.md has a definition.
#   4. Design documents carry no history: no revision notes, dated amendments or "kept for history" text
#      (sad.md, ux.md, req.md, lld/*.md). Dates belong in change_log.md, decision_log.md, facts.md, bugs.md, questions.md.
#   5. Register items (req, questions, decision_log, bugs) have a Status: line right under their heading.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SKILLS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; SKILLS="${SKILLS#"$ROOT"/}"
cd "$ROOT"
fail=0
say() { fail=1; printf '%s\n' "$*"; }

# ---- 1. files -------------------------------------------------------------
# Required: the core of the set. The optional registers (docs/ux.md, docs/facts.md, docs/bugs.md, docs/flows/)
# are checked only when present, so a project without a user interface or without bugs yet stays clean.
missing=0
for f in docs/sad.md docs/req.md docs/questions.md docs/decision_log.md docs/change_log.md docs/lld/README.md docs/lld/14-design-decisions.md; do
  [ -f "$f" ] || { say "missing file: $f"; missing=1; }
done
[ "$missing" -eq 0 ] || echo "  create the missing files with $SKILLS/spec-bootstrap/scripts/init-spec.sh"

# ---- 2. definitions ----------------------------------------------------------
# family -> file; the definition shapes are those of spec.sh
declare -A HOME=( [FR]=docs/req.md [NFR]=docs/req.md [OQ]=docs/questions.md [C]=docs/questions.md
  [FACT]=docs/facts.md [AD]=docs/decision_log.md [BUG]=docs/bugs.md [DES]=docs/lld/14-design-decisions.md
  [G]=docs/sad.md [NG]=docs/sad.md [BL]=docs/sad.md [A]=docs/sad.md [CON]=docs/sad.md [DEBT]=docs/sad.md
  [D]=docs/ux.md [UX]=docs/ux.md )
ID_RE='(FR|NFR|OQ|C|FACT|AD|BUG|DES|G|NG|BL|A|CON|DEBT|D)-[0-9]+|UX-[A-Z]+[0-9]+'
DEF_PREFIX='(#{2,4} |\| *\**|- *\**|\*\*)'
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# A definition is an item shape (heading, table row, list item, bold lead) in the family's HOME file.
# The same shape in any other file is a citation (a traceability row, a UX table that lists FRs, ...).
for fam in "${!HOME[@]}"; do
  f="${HOME[$fam]}"; [ -f "$f" ] || continue
  case "$fam" in UX) re='UX-[A-Z]+[0-9]+' ;; *) re="${fam}-[0-9]+" ;; esac
  grep -oE "^${DEF_PREFIX}(${re})([^0-9A-Za-z]|$)" "$f" 2>/dev/null | grep -oE "${re}" | awk -v f="$f" '{ print $0, f }'
done | sort > "$tmp/defs"

# duplicates (same ID defined twice in its home file)
awk '{ print $1 }' "$tmp/defs" | uniq -d > "$tmp/dups"
while read -r id; do
  [ -n "$id" ] || continue
  say "defined more than once: $id in $(awk -v id="$id" '$1 == id { f = $2 } END { print f }' "$tmp/defs")"
done < "$tmp/dups"
sort -u -o "$tmp/defs" "$tmp/defs"

# ---- 3. dangling citations ----------------------------------------------------
awk '{ print $1 }' "$tmp/defs" | sort -u > "$tmp/defined"
{ for f in docs/*.md docs/lld/*.md docs/flows/*.md; do [ -f "$f" ] && [ "$f" != docs/change_log.md ] && cat "$f"; done
  if [ -d docs/todo ]; then find docs/todo -name '*.md' -exec cat {} +; fi; } \
  | grep -oE "(^|[^0-9A-Za-z-])(${ID_RE})" | grep -oE "${ID_RE}" | sort -u > "$tmp/cited"
comm -13 "$tmp/defined" "$tmp/cited" > "$tmp/dangling"
if [ -s "$tmp/dangling" ]; then
  say "cited but never defined ($(wc -l < "$tmp/dangling")): $(tr '\n' ' ' < "$tmp/dangling")"
fi

# ---- 4. history in design documents -------------------------------------------
HIST_RE='kept for history|\*Amended|\*Later edit|^\*\*Revision|\(new 20[0-9]{2}|\b(amended|revised|revision|superseded|supersedes|resolved|added|changed|retired|withdrawn|deprecated|decided|later edit|owner (decision|order|request|confirmation|change request))\b[^|]{0,40}\b20[0-9]{2}-[0-9]{2}-[0-9]{2}\b'
HIST_LETTER_RE='\b20[0-9]{2}-[0-9]{2}-[0-9]{2} \([b-z]\)'   # "2026-10-09 (c)" revision letters; case-sensitive
for f in docs/sad.md docs/ux.md docs/req.md docs/lld/*.md docs/flows/*.md; do
  [ -f "$f" ] || continue
  awk '/^```/ { code = !code; next } !code { print NR ": " $0 }' "$f" \
    | { grep -iE "$HIST_RE" || true; } > "$tmp/hist_a"
  awk '/^```/ { code = !code; next } !code { print NR ": " $0 }' "$f" \
    | { grep -E "$HIST_LETTER_RE" || true; } > "$tmp/hist_b"
  cat "$tmp/hist_a" "$tmp/hist_b" | sort -t: -k1,1n -u | cut -c1-140 | sed "s|^|$f:|" > "$tmp/hist"
  if [ -s "$tmp/hist" ]; then
    say "history text in a design document ($(wc -l < "$tmp/hist") lines) — move it to docs/change_log.md:"
    head -8 "$tmp/hist" | sed 's/^/    /'
    [ "$(wc -l < "$tmp/hist")" -gt 8 ] && echo "    …"
  fi
done

# ---- 5. Status: lines ----------------------------------------------------------
for f in docs/req.md docs/questions.md docs/decision_log.md docs/bugs.md; do
  [ -f "$f" ] || continue
  awk -v f="$f" '
    /^### / { if (pending) print f ":" hn ": item without a Status: line: " head; pending = 1; hn = NR; head = $0; n = 0; next }
    pending { n++; if ($0 ~ /^Status:/) pending = 0; else if (n > 3) { print f ":" hn ": item without a Status: line: " head; pending = 0 } }
    END { if (pending) print f ":" hn ": item without a Status: line: " head }' "$f" > "$tmp/status" || true
  if [ -s "$tmp/status" ]; then say "$(head -5 "$tmp/status")"; [ "$(wc -l < "$tmp/status")" -gt 5 ] && echo "    … $(wc -l < "$tmp/status") items"; fi
done

if [ "$fail" -eq 0 ]; then
  echo "spec-check: clean ($(wc -l < "$tmp/defined") IDs defined, $(wc -l < "$tmp/cited") cited)"
fi
exit "$fail"
