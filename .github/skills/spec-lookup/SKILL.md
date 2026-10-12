---
name: spec-lookup
description: How to find a requirement, decision, question, fact, bug or LLD section by its ID without reading the specification documents whole. Load when a story, bug or request cites IDs such as FR-042, DES-103, OQ-53, AD-08, C-56, D-30 or "LLD 5.03", before reading any file under docs/.
metadata:
  version: "2.0.0"
---

# Spec lookup

The specification is split into registers so that one item can be read on its own. Read the items a
story cites, not the documents. `docs/sad.md`, `docs/ux.md`, `docs/req.md` and the `docs/lld/` files
are never read whole during a story: use the script, or a search and a bounded read with an offset.

## Where things live

| IDs | File | Holds |
|---|---|---|
| FR, NFR | `docs/req.md` | Requirements in their current wording, each with `Design:` (LLD sections, DES) and `Verification:` lines |
| OQ, C | `docs/questions.md` | Open questions (OQ) and cross-document clarifications (C), each with a status and the decision |
| FACT | `docs/facts.md` | Observed facts about the real data and the environment |
| AD | `docs/decision_log.md` | Architectural decisions in ADR form (context, decision, consequences) |
| BUG | `docs/bugs.md` | Bug register with status; the bug stories stay in `docs/todo/bugs/` |
| DES | `docs/lld/14-design-decisions.md` | Design decisions as one table; the area files cite them and hold the detailed contracts |
| G, NG, BL, A, CON, DEBT | `docs/sad.md` | Goals, non-goals, backlog, assumptions, constraints, technical debt; the architecture itself |
| D, UX-* | `docs/ux.md` | Data needs per view (D) and interface elements (`UX-<area><n>`) |
| LLD 4, LLD 5.03, … | `docs/lld/<number>-<slug>.md` | One file per LLD section; `docs/lld/README.md` is the index |
| — | `docs/flows/<action>.md` | Data-flow and workflow diagrams (Mermaid), one file per user action; `docs/flows/README.md` is the index |
| — | `docs/change_log.md` | Every change to a design document, by date. Read only when the history matters |
| — | `docs/todo/`, `docs/done/` | Stories; a done story is history and is read only as a dependency |

`docs/ux.md`, `docs/facts.md`, `docs/bugs.md` and `docs/flows/` are optional: a project without a user
interface, without recorded facts or without bugs yet may not have them.

## Commands

```bash
.github/skills/spec-lookup/scripts/spec.sh FR-042 DES-103 OQ-53   # the definition of each ID
.github/skills/spec-lookup/scripts/spec.sh --refs FR-042           # every citation (file:line), for impact analysis
.github/skills/spec-lookup/scripts/spec.sh --lld 5.03              # the whole LLD section file
.github/skills/spec-lookup/scripts/spec.sh --lld-path 5.03         # its path, to read with an offset
.github/skills/spec-lookup/scripts/spec.sh --files                 # this table
```

Sub-item suffixes are accepted (`FR-042(e)` prints FR-042). An ID the script cannot find has no
definition: report it as specification drift instead of guessing its meaning.

## Reading a story

1. Run `spec.sh` on every ID the story cites. That is the normative text.
2. Read the LLD section files the story names (`--lld 5.03`). A section file is small enough to read whole.
3. For UX work, read the `UX-` and `D-` items cited plus the one `docs/ux.md` subsection the story names
   (a search for `^### ` in `docs/ux.md` gives the offsets).
4. Read `docs/sad.md` only for architecture context (Sections 6 to 9) and only the section that applies.
5. Do not read `docs/change_log.md`, `docs/done/` or `docs/decision_log.md` unless the story asks why
   something is the way it is.

An agent that cannot run commands searches for `^### FR-042` in `docs/req.md` and reads from that offset
with a small limit; a table-row item is one search result line.
