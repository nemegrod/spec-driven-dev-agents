#!/usr/bin/env bash
# install.sh — install the spec-driven delivery suite into a repository.
#
#   install.sh <target-repository> --claude      Claude Code:    .claude/agents, .claude/skills, CLAUDE.md
#   install.sh <target-repository> --copilot     GitHub Copilot: .github/agents, .github/skills,
#                                                                .github/copilot-instructions.md
#   Both flags together install both variants. One of them is required.
#
#   --no-ux      do not create docs/ux.md (a product with no user interface)
#   --dry-run    list what would be copied and created, change nothing
#
# Copy-when-absent: a file that already exists in the target is never overwritten. Files that differ
# from the packaged version are listed so they can be compared and merged by hand. Only the agents and
# skills folders are copied; nothing else under the target's .claude/ or .github/ is touched.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
usage() { sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; }
[ $# -ge 1 ] || { usage; exit 1; }
case "$1" in -h|--help) usage; exit 0 ;; esac
[ -d "$1" ] || { echo "install.sh: $1 is not a directory" >&2; exit 1; }
DST="$(cd "$1" && pwd)"; shift
[ "$DST" != "$SRC" ] || { echo "install.sh: the target is this distribution repository" >&2; exit 1; }

dry=0; homes=(); init_args=()
for arg in "$@"; do
  case "$arg" in
    --claude)  homes+=(".claude") ;;
    --copilot) homes+=(".github") ;;
    --dry-run) dry=1; init_args+=("--dry-run") ;;
    --no-ux)   init_args+=("--no-ux") ;;
    *)         echo "install.sh: unknown option $arg" >&2; exit 1 ;;
  esac
done
[ "${#homes[@]}" -gt 0 ] || { echo "install.sh: choose --claude, --copilot or both" >&2; exit 1; }

for home in "${homes[@]}"; do
  copied=0; same=0; differs=()
  echo "Installing $home/agents and $home/skills into $DST"
  while IFS= read -r src; do
    rel="${src#"$SRC"/}"; dst="$DST/$rel"
    if [ -e "$dst" ]; then
      if cmp -s "$src" "$dst"; then same=$((same + 1)); else differs+=("$rel"); fi
      continue
    fi
    copied=$((copied + 1))
    if [ "$dry" -eq 1 ]; then echo "  would copy $rel"; continue; fi
    mkdir -p "$(dirname "$dst")"
    cp -p "$src" "$dst"
  done < <(find "$SRC/$home/agents" "$SRC/$home/skills" -type f | sort)

  echo "$copied copied, $same identical, ${#differs[@]} kept because they differ."
  if [ "${#differs[@]}" -gt 0 ]; then
    echo "Compare and merge by hand:"
    printf '  %s\n' "${differs[@]}"
  fi

  init="$DST/$home/skills/spec-bootstrap/scripts/init-spec.sh"
  echo
  if [ -x "$init" ]; then
    "$init" "${init_args[@]+"${init_args[@]}"}"
  else
    echo "Then: $home/skills/spec-bootstrap/scripts/init-spec.sh creates the docs/ skeleton and the instruction file."
  fi
  echo
done
