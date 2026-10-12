#!/usr/bin/env bash
# spec.sh — print specification items by ID without reading whole documents.
#
#   spec.sh FR-042 DES-103 OQ-53     print the definition of each ID
#   spec.sh --refs FR-042            list every citation of an ID (file:line), definition excluded
#   spec.sh --lld 5.40               print the LLD file for a section number (--lld-path: path only)
#   spec.sh --files                  print the file map (which register holds which ID family)
#
# Item shapes recognised as a definition (see the spec-authoring skill):
#   ### ID — Title            heading item: printed until the next heading
#   | ID | ...                table row: printed with its table header
#   - ID: ... / - **ID** ...  list item: printed with indented continuation lines
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"

files_for() {            # family -> files holding its definitions
  case "$1" in
    FR|NFR)              echo "docs/req.md" ;;
    OQ|C)                echo "docs/questions.md" ;;
    FACT)                echo "docs/facts.md" ;;
    AD)                  echo "docs/decision_log.md" ;;
    BUG)                 echo "docs/bugs.md" ;;
    DES)                 echo "docs/lld/14-design-decisions.md" ;;
    G|NG|BL|A|CON|DEBT)  echo "docs/sad.md" ;;
    D|UX-*)              echo "docs/ux.md" ;;
    *)                   return 1 ;;
  esac
}

print_map() {
  cat <<'EOF'
FR, NFR            docs/req.md                       requirements (current wording, Design: and Verification: lines)
OQ, C              docs/questions.md                 open questions (OQ) and cross-document clarifications (C)
FACT               docs/facts.md                     observed facts about the real data and environment
AD                 docs/decision_log.md              architectural decisions (ADR form)
BUG                docs/bugs.md                      bug register; stories stay in docs/todo/bugs/
DES                docs/lld/14-design-decisions.md   design decisions; the area files cite them
G, NG, BL, A, CON  docs/sad.md                       goals, non-goals, backlog, assumptions, constraints
DEBT               docs/sad.md                       technical debt (Section 11)
D, UX-*            docs/ux.md                        data needs per view, interface elements
LLD 5.NN / N       docs/lld/<number>-<slug>.md       one file per LLD section (index: docs/lld/README.md)
history            docs/change_log.md                every change to a design document, by date
EOF
}

print_item() {           # $1 = ID, $2 = file
  local id="$1" f="$2"
  [ -f "$f" ] || { echo "spec.sh: $f is missing" >&2; return 1; }
  awk -v id="$id" '
    function esc(s) { gsub(/[.^$*+?()[\]{}|\\]/, "\\\\&", s); return s }
    BEGIN { re = esc(id) "([^0-9A-Za-z]|$)"; found = 0 }
    {
      line[NR] = $0
      if (!found) {
        if ($0 ~ ("^#{2,4} " re))                  { found = NR; kind = "h" }
        else if ($0 ~ ("^\\| *\\**" re))          { found = NR; kind = "t" }
        else if ($0 ~ ("^- *\\**" re))            { found = NR; kind = "l" }
        else if ($0 ~ ("^\\*\\*" re))             { found = NR; kind = "b" }
      }
    }
    END {
      if (!found) exit 2
      if (kind == "h") {
        end = NR
        for (i = found + 1; i <= NR; i++) if (line[i] ~ /^#/) { end = i - 1; break }
        while (end > found && line[end] ~ /^[[:space:]]*$/) end--
        for (i = found; i <= end; i++) print line[i]
      } else if (kind == "t") {
        for (i = found - 1; i > 0 && line[i] ~ /^\|/; i--) hdr = i
        if (hdr) { print line[hdr]; print line[hdr + 1] }
        print line[found]
      } else {
        print line[found]
        for (i = found + 1; i <= NR && line[i] ~ /^[[:space:]]+[^[:space:]]/; i++) print line[i]
      }
    }' "$f"
}

lookup() {               # $1 = ID (sub-item suffixes such as (e) are stripped)
  local id fam rc=0
  id="$(printf '%s' "$1" | sed -E 's/\([a-z0-9]+\)$//')"
  fam="${id%-*}"
  case "$id" in UX-*) fam="UX-${id#UX-}"; fam="${fam%%[0-9]*}" ;; esac
  local f
  if ! f="$(files_for "$fam")"; then echo "spec.sh: unknown ID family in '$1'" >&2; return 1; fi
  echo "── $id  ($f)"
  print_item "$id" "$f" || { echo "spec.sh: $id has no definition in $f (try --refs $id)" >&2; rc=1; }
  echo
  return $rc
}

refs() {
  local id="$1" fam f
  fam="${id%-*}"; case "$id" in UX-*) fam="UX-${id#UX-}"; fam="${fam%%[0-9]*}" ;; esac
  f="$(files_for "$fam" 2>/dev/null || true)"
  grep -rnE "(^|[^0-9A-Za-z-])${id}([^0-9A-Za-z]|$)" docs --include='*.md' \
    | { if [ -n "$f" ]; then grep -vE "^${f}:[0-9]+:(#{2,4} |\| *\**|- *\**|\*\*)${id}([^0-9A-Za-z]|$)"; else cat; fi; } || true
}

lld_file() {
  local n="$1" m
  m="$(ls docs/lld/ | grep -E "^0?${n//./\\.}-" | head -1 || true)"
  [ -n "$m" ] || { echo "spec.sh: no LLD file for section $n (see docs/lld/README.md)" >&2; return 1; }
  echo "docs/lld/$m"
}

[ $# -gt 0 ] || { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
case "$1" in
  --files)    print_map ;;
  --refs)     shift; for id in "$@"; do refs "$id"; done ;;
  --lld)      shift; for n in "$@"; do f="$(lld_file "$n")" && cat "$f"; done ;;
  --lld-path) shift; for n in "$@"; do lld_file "$n"; done ;;
  --*)        echo "spec.sh: unknown option $1" >&2; exit 1 ;;
  *)          rc=0; for id in "$@"; do lookup "$id" || rc=1; done; exit $rc ;;
esac
