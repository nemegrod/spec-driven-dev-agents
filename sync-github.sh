#!/usr/bin/env bash
# sync-github.sh — rebuild the GitHub Copilot variant (.github/) from the Claude Code variant (.claude/).
#
# .claude/ is the source. Edit there, then run this script. Never edit .github/agents or .github/skills
# by hand: the next run replaces them. Nothing else under .github/ is touched.
#
#   agents    same body; the frontmatter tools become Copilot tool sets, model and effort are dropped
#   skills    copied; folder paths and the instruction-file name are rewritten in every Markdown file
#   scripts   copied unchanged (they locate their own folder at run time)
#
#   sync-github.sh           rebuild
#   sync-github.sh --check   rebuild into a temporary folder and fail when .github/ differs (for CI)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

rewrite() {               # stdin -> stdout: Claude Code paths and names to their Copilot equivalents
  sed -e 's|templates/CLAUDE\.md|templates/copilot-instructions.md|g' \
      -e 's|\.claude/skills|.github/skills|g' \
      -e 's|\.claude/agents|.github/agents|g' \
      -e 's|CLAUDE\.md|.github/copilot-instructions.md|g'
}

frontmatter() {           # $1 = agent file -> stdout with Copilot frontmatter
  awk '
    NR == 1 && $0 == "---" { fm = 1; print; next }
    fm && $0 == "---"      { fm = 0; print; next }
    fm && /^(model|effort):/ { next }
    fm && /^tools:/ {
      t = $0; sub(/^tools:[ ]*\[/, "", t); sub(/\][ ]*$/, "", t)
      n = split(t, a, /,[ ]*/); run = 0; web = 0
      for (i = 1; i <= n; i++) {
        if (a[i] ~ /^(Read|Glob|Grep|Edit|Write)$/) continue
        else if (a[i] == "Bash") run = 1
        else if (a[i] ~ /^(WebFetch|WebSearch)$/) web = 1
        else { print "sync-github.sh: unknown tool " a[i] " in " FILENAME > "/dev/stderr"; exit 3 }
      }
      out = "read, edit, search"; if (run) out = out ", execute"; if (web) out = out ", web"
      print "tools: [" out "]"; next
    }
    { print }' "$1"
}

build() {                 # $1 = destination folder that receives agents/ and skills/
  local out="$1" f
  rm -rf "$out/agents" "$out/skills"
  mkdir -p "$out/agents"
  for f in .claude/agents/*.agent.md; do
    frontmatter "$f" | rewrite > "$out/agents/$(basename "$f")"
  done
  cp -Rp .claude/skills "$out/skills"
  mv "$out/skills/spec-bootstrap/templates/CLAUDE.md" "$out/skills/spec-bootstrap/templates/copilot-instructions.md"
  while IFS= read -r f; do
    rewrite < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  done < <(find "$out/skills" -type f -name '*.md')
  if grep -rnE '\.claude|CLAUDE' "$out/agents" "$out/skills" --include='*.md'; then
    echo "sync-github.sh: a Claude Code path or name survived the rewrite (lines above)" >&2; return 1
  fi
}

if [ "${1:-}" = "--check" ]; then
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  build "$tmp"
  if diff -r "$tmp/agents" .github/agents >/dev/null && diff -r "$tmp/skills" .github/skills >/dev/null; then
    echo "sync-github.sh: .github/ is in sync with .claude/"
  else
    echo "sync-github.sh: .github/ is out of date; run sync-github.sh" >&2; exit 1
  fi
else
  build .github
  echo "sync-github.sh: $(find .github/agents -type f | wc -l) agents and $(find .github/skills -type f | wc -l) skill files written to .github/"
fi
