# Copilot Instructions — Spec-Driven Delivery

## Design Authority

Before making changes, read the relevant design documents:

- **Solution architecture:** `docs/sad.md` — system boundaries, components, and integration points.
- **Low-level design:** `docs/lld.md` — implementation patterns, data structures, module boundaries, dependencies, and code conventions.

Treat these documents as the source of truth. Do not invent a new data structure, abstraction, utility, or dependency before checking whether the LLD already defines one. 

## Change Workflow

- Keep changes within the architecture and module boundaries defined in the SAD and LLD.
- Keep production implementation, code review, and testing separate: the Developer changes production, the Code Review Agent independently reviews without fixing, and the Test Agent owns test assets and validation.
- Test assets and generated artifacts use the locations and conventions defined in `docs/lld.md` and the active work item.
- For stories in `docs/todo/`, the Developer records the implementation handoff, the Code Review Agent records independent review evidence, the Test Agent records independent validation evidence, and the Scrum Master marks validated stories done and moves them to `docs/done/`.