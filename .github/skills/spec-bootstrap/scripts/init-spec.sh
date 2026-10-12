#!/usr/bin/env bash
# init-spec.sh — create the skeleton of the specification set in this repository.
#
#   init-spec.sh              create every missing file under docs/, and the instruction file when absent
#   init-spec.sh --no-ux      the same, without docs/ux.md (a product with no user interface)
#   init-spec.sh --dry-run    list what would be created, change nothing
#
# A file that already exists is never overwritten or changed, so the script is safe to run again:
# it fills in only what is missing (for example docs/ux.md once the product gets a user interface).
#
# The always-loaded instruction file follows the folder this skill is installed in:
#   .claude/skills/  ->  CLAUDE.md                          (Claude Code)
#   .github/skills/  ->  .github/copilot-instructions.md    (GitHub Copilot)
set -euo pipefail

SKILL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$SKILL/../../.." && pwd)"
TPL="$SKILL/templates"
case "$(basename "$(cd "$SKILL/../.." && pwd)")" in
  .github) INSTR_SRC="$TPL/copilot-instructions.md"; INSTR_DST=".github/copilot-instructions.md" ;;
  *)       INSTR_SRC="$TPL/CLAUDE.md";               INSTR_DST="CLAUDE.md" ;;
esac
MARKER='<!-- spec-driven-delivery -->'

ux=1; dry=0
for arg in "$@"; do
  case "$arg" in
    --no-ux)   ux=0 ;;
    --dry-run) dry=1 ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         echo "init-spec.sh: unknown option $arg" >&2; exit 1 ;;
  esac
done

cd "$ROOT"
created=0; kept=0

place() {                 # $1 = template file, $2 = destination relative to the repository root
  if [ -e "$2" ]; then kept=$((kept + 1)); return 0; fi
  created=$((created + 1))
  if [ "$dry" -eq 1 ]; then echo "  would create $2"; return 0; fi
  mkdir -p "$(dirname "$2")"
  cp "$1" "$2"
  echo "  created $2"
}

echo "Specification skeleton in $ROOT"
while IFS= read -r src; do
  rel="${src#"$TPL"/}"
  if [ "$ux" -eq 0 ] && [ "$rel" = "docs/ux.md" ]; then continue; fi
  if [ "$rel" = "docs/change_log.md" ] && [ ! -e "$rel" ] && [ "$dry" -eq 0 ]; then
    place "$src" "$rel"
    printf '\n## %s\n\n- Specification set created from the `spec-bootstrap` skeletons. Orchestrator.\n' "$(date +%F)" >> "$rel"
    continue
  fi
  place "$src" "$rel"
done < <(find "$TPL/docs" -type f | sort)

if [ ! -e "$INSTR_DST" ]; then
  place "$INSTR_SRC" "$INSTR_DST"
elif ! grep -qF "$MARKER" "$INSTR_DST"; then
  echo "  $INSTR_DST exists and was left unchanged: merge the sections of"
  echo "    ${INSTR_SRC#"$ROOT"/} into it by hand."
else
  kept=$((kept + 1))
fi

echo "$created created, $kept already present."
[ "$dry" -eq 0 ] || exit 0

echo
"$SKILL/../spec-authoring/scripts/spec-check.sh" || true
cat <<'EOF'

Next:
  1. Solution Architect   context, scope, requirements, architecture   docs/sad.md, docs/req.md
  2. Design/UX Agent      only with a user interface                   docs/ux.md
  3. Software Architect   implementation contracts and flows          docs/lld/, docs/flows/
  4. Scrum Master         epics, features and stories                  docs/todo/
EOF
