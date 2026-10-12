---
name: spec-authoring
description: How to write and change the specification set (docs/sad.md, docs/req.md, docs/ux.md, docs/lld/, docs/flows/, docs/questions.md, docs/facts.md, docs/decision_log.md, docs/bugs.md, docs/change_log.md) - item formats, ID rules, ownership, and the rule that design documents describe the present while history goes to the change log. Load before editing any file under docs/ other than a story.
metadata:
  version: "2.0.0"
---

# Spec authoring

Two rules carry everything else:

1. **A design document describes the current design.** `docs/sad.md`, `docs/req.md`, `docs/ux.md`,
   `docs/lld/*.md` and `docs/flows/*.md` say what is, never what was or when it changed. No revision
   blocks, no "(amended 2026-03-08)", no "owner, verbatim: …", no "kept for history", no dates on items.
2. **History goes to `docs/change_log.md`.** Every change to a design document gets one entry there:
   what changed, which IDs, who decided. A reader who wants the "why" reads the change log or the
   decision log; everyone else reads the present.

`spec-check.sh` enforces both (Section 6). Load `spec-lookup` for reading; this skill is for writing.
A file that does not exist yet is created from its skeleton: load `spec-bootstrap`.

## 1. Ownership

| File | Owner |
|---|---|
| `docs/sad.md`, `docs/req.md`, `docs/questions.md` (OQ), `docs/facts.md`, `docs/decision_log.md` | Solution Architect |
| `docs/ux.md`, `docs/questions.md` (C items) | Design/UX Agent |
| `docs/lld/*.md` including `14-design-decisions.md`; `docs/flows/*.md` | Software Architect |
| `docs/bugs.md`, `docs/todo/`, `docs/done/` | Scrum Master (the implementing, reviewing and testing roles write their own sections inside a story) |
| `docs/change_log.md` | everyone appends |

An owner never changes another owner's file. A gap found downstream is reported upstream (Developer to
Software Architect to Solution Architect) through the story's Blockers or the report to the orchestrator.

## 2. IDs

- Families: `FR`, `NFR` (requirements); `OQ`, `C` (questions); `FACT`; `AD`; `BUG`; `DES`; `G`, `NG`,
  `BL`, `A`, `CON`, `DEBT` (SAD); `D`, `UX-<area><n>` (UX). Zero-padded as the family already is
  (`FR-080`, `AD-28`, `OQ-91`, `DES-188`).
- `scripts/next-id.sh FR` prints the next free number. Without a shell, search `docs/` for the family
  prefix and take the highest number plus one. Numbers are never reused and never renumbered.
- An item is defined exactly once, in its family's file (table in `spec-lookup`). Everything else
  cites it by ID. Sub-items are lettered inside the item: `(a)`, `(b)`; cite them as `FR-042(e)`.
- An item that no longer applies is not deleted: it keeps its ID with `Status: void` (requirements),
  `superseded by AD-nn` (decisions) or `dropped` (questions) and one line saying what replaced it, so
  citations still resolve. The reason and the date go to the change log.
- A project that already has a coherent ID scheme keeps it; add its families to the two scripts.

## 3. Item formats

**Heading items** (`req.md`, `questions.md`, `facts.md`, `decision_log.md`, `bugs.md`): one `###` per
item, no other `###` headings in those files, no headings inside an item, a blank line between items.
The `Status:` line is the first line under the heading; `spec-check.sh` requires it (facts excepted).
The examples below use placeholder numbers (`nnn`); a real item carries its number.

```markdown
### FR-nnn — Exports carry the time they were generated
Status: active                      # active | void | deferred
Priority: Must                      # Must | Should | Could (FR only)
Design: LLD 5.03, 7; DES-nnn
Verification: Unit (export writer), integration (download route)

(a) Every exported file states the time it was generated, in UTC …
(b) …
```

```markdown
### OQ-nn — Should an export include archived records?
Status: resolved                    # open | resolved | dropped
Decision: No. Archived records are exported only on request (FR-nnn(c)).
Decides: owner
Affects: FR-nnn, LLD 5.03

The question in one or two sentences. Resolved items keep the question, not the deliberation.
```

```markdown
### AD-nn — Exports are generated on request, never scheduled
Status: active                      # active | superseded by AD-nn
Decided: 2026-01-15 by the owner
Context: …
Decision: …
Consequences: …
```

```markdown
### BUG-nnn — Export fails when the record set is empty
Status: open                        # open | fixed | wontfix
Story: docs/todo/bugs/BUG-nnn-export-fails-on-empty-set.md
Affects: FR-nnn, DES-nnn

One paragraph: symptom, cause if known, scope.
```

```markdown
### FACT-n — The upstream feed delivers one file per day
Observed: 2026-01-12
What was seen, where, and how it was verified. Sample values are invented, never real records.
```

**Table items** (`sad.md` G/NG/BL/A/CON/DEBT, `ux.md` D, `lld/14-design-decisions.md` DES): one row per
item, the ID in the first cell, the row is the whole definition. A `DES` row is
`| DES-nnn | decision in one or two sentences | traces to | rationale |`; the detailed contract lives in
the area file (`docs/lld/5.03-<slug>.md`), which cites the DES in its heading or text and does not
restate the row.

**UX items** (`ux.md` UX-*): a bold lead in the surface's subsection, `**UX-G1 Account selector.** text …`,
or a table row with the ID in the first cell. The area letters are the document's own (`UX-G` global,
`UX-D` dashboard, and so on); a new surface takes a new letter group.

**Flow files** (`docs/flows/<action>.md`) have a fixed shape: one paragraph, `## Overview` (`flowchart LR`,
edge labels carry the data, `WRITE` marks writes to a data store), `## Detailed workflow`
(`sequenceDiagram` with `autonumber`, every request and every data-store round trip as a message, `alt`
branches with the status and error code), `## Data` table, `## Failure paths`, `## References`. When a
contract in the LLD changes, the flow file that draws it changes in the same edit. Quote Mermaid labels
that contain spaces or punctuation; no `;`, `|`, brackets or quotes inside labels.

**LLD section files** keep their section number in the heading (`## 4. Data Contracts`,
`### 5.03 Export writer (…)`), one file per section, listed in `docs/lld/README.md`. A new area gets the
next `5.NN` number and a new file `5.NN-<slug>.md`. Delivery orders for story slicing are not design:
they go into the stories and the change log.

## 4. Changing an item

1. Edit the item in place to its new current wording. Remove nothing that still applies.
2. If the change resolves an OQ or C: set its `Status:` and `Decision:` in `questions.md`, then fold
   the outcome into the design text (requirement, UX item, LLD contract). The question text itself
   stays short.
3. If it changes or reverses a decision: new AD or DES row (or update the row), and
   `Status: superseded by …` on the old one.
4. Append to `docs/change_log.md` under today's date (sections in ascending date order, one
   `## YYYY-MM-DD` per day, newest at the bottom):

   ```markdown
   ## 2026-01-15
   - **FR-nnn(c), AD-nn** — archived records are exported only on request. Owner decision.
     (`docs/req.md`, `docs/lld/5.03-export-writer.md`)
   - **OQ-nn** resolved: no scheduled exports. Owner.
   ```

   One bullet per change: IDs in bold first, then what changed and who decided, then the files touched.
   The owner's words are paraphrased; a verbatim quote is kept only when the wording itself is the decision.
5. Update `Design:` and `Verification:` on the affected requirements when the LLD mapping moves.

## 5. Writing style for design text

- Present tense, declarative: "The panel shows …", not "The panel will show …" or "was changed to show …".
- Requirements cite constraints and facts by ID; the LLD cites requirements and UX items by ID and
  UX subsection; the UX cites requirements and D items. Never copy text across documents.
- No personal data, credentials, real customer or production records, or machine-local paths. Sample
  data is invented and marked as such.
- An example illustrates a contract and never contradicts it; when they disagree, fix the example.

## 6. Check before you report

```bash
.github/skills/spec-authoring/scripts/spec-check.sh
```

It reports missing core files, duplicate or misplaced definitions, dangling citations, history text in a
design document and register items without `Status:`. It exits 0 when clean and 1 with findings, so any
test runner or CI step can call it. `guards/test_spec_registers.py` in this skill is a ready pytest
wrapper: copy it into the project's test folder when the project uses pytest; the LLD's verification
section records where the guard lives. An agent without a shell states in its report that the check
still has to be run, and the orchestrator runs it.
