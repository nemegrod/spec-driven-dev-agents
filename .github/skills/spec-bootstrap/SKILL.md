---
name: spec-bootstrap
description: How to start the specification set in a repository that has none, or add a register that is missing - the skeleton of every file under docs/, the script that creates them, the section layout the agents refer to, and the order in which the roles first run. Load when docs/ or one of its registers (sad.md, req.md, ux.md, lld/, questions.md, facts.md, decision_log.md, bugs.md, change_log.md, flows/, todo/) does not exist yet.
metadata:
  version: "1.0.0"
---

# Spec bootstrap

The agents and the `spec-lookup` and `spec-authoring` skills assume the specification set exists. This
skill creates it. After that it is not needed again until a register is missing.

## 1. Create the skeleton

```bash
.github/skills/spec-bootstrap/scripts/init-spec.sh            # every missing file, and .github/copilot-instructions.md when absent
.github/skills/spec-bootstrap/scripts/init-spec.sh --no-ux    # a product with no user interface
.github/skills/spec-bootstrap/scripts/init-spec.sh --dry-run  # list only
```

The script never overwrites or changes an existing file, so it is safe to run again. It ends by running
`spec-check.sh`, which is clean on an empty set. An agent without a shell copies the one file it owns
from `.github/skills/spec-bootstrap/templates/docs/` to the same path under `docs/`.

A skeleton holds headings, empty tables and one italic line per section saying what belongs there.
The owner replaces each italic line with content. A section that does not apply keeps its heading and
says "Not applicable" with the reason, so the numbering stays stable.

## 2. The layout the agents rely on

The agent files and skills cite these sections by number. Do not renumber, rename or merge them.

| File | Owner | Layout |
|---|---|---|
| `docs/sad.md` | Solution Architect | 1 Context and Problem, 2 Stakeholders and Outcomes, 3 Scope (goals, non-goals, backlog, system boundary), 4 Requirements (constraints), 5 Assumptions and Open Questions, 6 Solution Architecture, 7 Integrations, 8 Security, Privacy and Trust, 9 Key Architectural Decisions, 10 Requirement Traceability, 11 Risks and Technical Debt |
| `docs/req.md` | Solution Architect | "Functional requirements", then "Quality attributes"; one `###` item per requirement |
| `docs/questions.md` | Solution Architect (OQ), Design/UX Agent (C) | "Open questions", then "Clarifications"; one `###` item per question |
| `docs/facts.md`, `docs/decision_log.md` | Solution Architect | One `###` item per fact or decision |
| `docs/ux.md` | Design/UX Agent | 1 Design Direction, 2 Information Architecture, 3 Surfaces (one subsection each), 4 Shared Components, 5 Data Needs per View, 6 Open Items |
| `docs/lld/` | Software Architect | `README.md` (index), `01-design-scope`, `02-current-state`, `03-module-boundaries`, `04-data-contracts`, `5.NN-<slug>` (one interface area per file), `06-program-flow`, `07-failure-semantics`, `08-security-privacy`, `09-configuration-dependencies`, `10-observability`, `11-migration-compatibility`, `12-verification-design`, `13-traceability`, `14-design-decisions` (the DES register), `15-project-conventions`, `16-open-design-issues` |
| `docs/flows/` | Software Architect | `README.md` (system data flow and index), then one file per user action |
| `docs/bugs.md` | Scrum Master | One `###` item per bug |
| `docs/todo/`, `docs/done/` | Scrum Master | `todo/README.md` lists the epics; `todo/<epic>/README.md` lists features and stories; `todo/<epic>/<feature>/<id>-<slug>.md`; `todo/bugs/`; done stories flat in `done/` |
| `docs/change_log.md` | everyone appends | One `## YYYY-MM-DD` section per day, oldest first |

Optional files: `docs/ux.md` (no user interface), `docs/facts.md`, `docs/bugs.md`, `docs/flows/`.
`spec-check.sh` requires the others.

## 3. First run, by role

| Order | Role | Produces | Starts when |
|---|---|---|---|
| 1 | Orchestrator | The skeleton (`init-spec.sh`) | The repository has no `docs/` set |
| 2 | Solution Architect | `sad.md` Sections 1 to 11, the FR and NFR items, facts, questions, decisions | The user has given the business context |
| 3 | Design/UX Agent | `ux.md`, D and UX items | The requirements with a user interface are approved |
| 4 | Software Architect | The LLD files, the DES rows, the flows, and each requirement's `Design:` and `Verification:` lines | No requirement it must design is behind an open question |
| 5 | Scrum Master | Epics, features and stories | The LLD covers the requirements in scope |
| 6 | Developer or Design/UX Agent, Code Review Agent, Test Agent | Per story: implementation, review, validation | The Scrum Master has activated the story |

A role that finds its input missing does not create it: it reports the gap to the owner above it.

## 4. What belongs outside the skeleton

- **Stack, commands and paths**: `docs/lld/12-verification-design.md` and `docs/lld/15-project-conventions.md`.
- **Domain rules that several roles must apply** (a data store's modelling rules, a design system's
  wiring): a domain skill under `.github/skills/`. `templates/domain-skill/SKILL.template.md` is the
  starting point: a description that says when to load it, a per-role table of obligations, short
  numbered sections, and a review checklist.
- **Orchestration rules**: the repository's `.github/copilot-instructions.md`.

The agent files stay free of project facts, so they can be replaced by a newer version of the suite.
