<!-- spec-driven-delivery -->
# Spec-driven delivery

This repository is built specification first. The specification under `docs/` is the source of truth, and seven role agents under `.claude/agents/` each own one part of the work. Whoever routes the work, the main chat session or the person selecting the agents, is the orchestrator: the orchestrator sends work to the roles and does not do their work itself.

## Design authority

- Read specification items by ID with the `spec-lookup` skill. Never read `docs/sad.md`, `docs/req.md`, `docs/ux.md` or the `docs/lld/` folder whole.
- Write specification files only as the `spec-authoring` skill says: design documents describe the present, and every change gets one entry in `docs/change_log.md`.
- Do not invent a data structure, abstraction, utility or dependency before checking whether the LLD already defines one.
- Project facts (stack, commands, paths, conventions) live in the specification, mainly `docs/lld/12-verification-design.md` and `docs/lld/15-project-conventions.md`, and in the project's domain skills. They do not belong in the agent files.

## Roles

| Role | Owns | Runs when |
|---|---|---|
| Solution Architect | `docs/sad.md`, `docs/req.md`, `docs/questions.md` (OQ), `docs/facts.md`, `docs/decision_log.md` | A need, a scope change or an open question arrives |
| Design/UX Agent | `docs/ux.md`, the C items in `docs/questions.md`; implements frontend stories | Requirements with a user interface are approved; a frontend story is active |
| Software Architect | `docs/lld/`, `docs/flows/` | Requirements, and the UX items when there are any, are approved |
| Scrum Master | `docs/todo/`, `docs/done/`, `docs/bugs.md` | The LLD covers the requirements; a story reaches closure or is blocked |
| Developer | Production code; the Implementation Handoff of its story | A story is active with `current_owner: developer` |
| Code Review Agent | The Code Review section of the story | A story is in `review` |
| Test Agent | Test assets; the Validation section of the story | A story is in `testing` |

## Starting from an empty repository

1. Run `.claude/skills/spec-bootstrap/scripts/init-spec.sh` once. It creates the skeleton of every register and never overwrites a file.
2. Solution Architect: context, scope, constraints, requirements, architecture and decisions.
3. Design/UX Agent, when the product has a user interface: `docs/ux.md`.
4. Software Architect: the LLD sections and the flows, and the `Design:` and `Verification:` lines of the requirements.
5. Scrum Master: epics, features and stories under `docs/todo/`.
6. Per story: the implementing role, then Code Review, then Test, then Scrum Master closure.

## Orchestration rules

- One story per agent run. Give the agent the story path; it reads the items the story cites.
- Follow the story's `workflow_stage` and `current_owner`. Never skip review or testing that the story classifies as required.
- After any agent changes a file under `docs/`, run `.claude/skills/spec-authoring/scripts/spec-check.sh`. The architect agents have no shell, so this check is the orchestrator's.
- The Test Agent tests at MVP level unless the story says otherwise, and no agent runs the whole test suite unless the story or the user asks.
- A gap goes to the role that owns it. Do not patch a specification, a test or production code outside the owning role to get past a blocker.
- Nothing is committed, pushed, merged or deployed unless the user asks.
- No secrets, personal data or real records in code, tests, fixtures, logs or documents.
