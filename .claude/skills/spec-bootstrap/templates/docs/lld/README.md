# Low-Level Design

**Owner:** Software Architect

**Input:** `docs/req.md`, `docs/sad.md`, `docs/ux.md`

The LLD is one file per section and describes the current implementation design only; every change is recorded in `docs/change_log.md`. Cite a section as `LLD 4` or `LLD 5.03` (the heading keeps its number); `.claude/skills/spec-lookup/scripts/spec.sh --lld 5.03` prints it. Design decisions are rows in `14-design-decisions.md`; the area files cite them and hold the detailed contracts. A new area gets the next `5.NN` number, a file `5.NN-<slug>.md` and a row in this table.

| Section | File | Title |
|---|---|---|
| 1 | [01-design-scope.md](01-design-scope.md) | Design Scope |
| 2 | [02-current-state.md](02-current-state.md) | Current State |
| 3 | [03-module-boundaries.md](03-module-boundaries.md) | Module and Dependency Boundaries |
| 4 | [04-data-contracts.md](04-data-contracts.md) | Data Contracts |
| 6 | [06-program-flow.md](06-program-flow.md) | Program Flow and State |
| 7 | [07-failure-semantics.md](07-failure-semantics.md) | Failure Semantics |
| 8 | [08-security-privacy.md](08-security-privacy.md) | Security and Privacy |
| 9 | [09-configuration-dependencies.md](09-configuration-dependencies.md) | Configuration and Dependencies |
| 10 | [10-observability.md](10-observability.md) | Observability and Operations |
| 11 | [11-migration-compatibility.md](11-migration-compatibility.md) | Migration, Compatibility and Rollback |
| 12 | [12-verification-design.md](12-verification-design.md) | Verification Design |
| 13 | [13-traceability.md](13-traceability.md) | Traceability |
| 14 | [14-design-decisions.md](14-design-decisions.md) | Design Decisions |
| 15 | [15-project-conventions.md](15-project-conventions.md) | Project Conventions |
| 16 | [16-open-design-issues.md](16-open-design-issues.md) | Open Design Issues |

Section 5 is the interfaces, one area per file (`5.NN-<slug>.md`), added to this table as they are designed.
