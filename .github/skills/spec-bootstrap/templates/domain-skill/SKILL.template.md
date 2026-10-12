---
name: <kebab-case-name>
description: <What the skill covers, in this project.> Load before <deciding, designing, implementing, reviewing or testing> anything that touches <the area; the last section names the files>. The intro table says which sections each role applies.
metadata:
  version: "1.0.0"
---

# <Title>

<Two or three sentences: what this area is, why it needs its own rules, and which documents stay the
authority when this skill and a specification item disagree. A disagreement is drift to report.>

## When to load this skill, and what each role owes it

| Role | Load it before | Obligation |
|---|---|---|
| Solution Architect | <deciding …> | <which sections apply, and what the SAD must state because of them> |
| Software Architect | <designing a contract that touches …> | <which sections apply, and what counts as a defect in the LLD> |
| Developer | <editing …> | <which sections to follow; what to do when the LLD and this skill conflict> |
| Design/UX Agent | <writing …> | <which sections to follow; what must be reused before anything is written by hand> |
| Code Review Agent | <reviewing a change that touches …> | Run the checklist in the last section but one. Each "no" is a finding at Major severity or above, cited by file and line |
| Test Agent | <testing a story that …> | <what to assert or which guard tests to run> |

Delete the rows of roles the skill does not address.

## 1. <Principles>

<Short rules, each one checkable. Every section is short enough to read whole.>

## 2. <How it is wired in this project>

<Files, modules, tokens, commands. Verified against the code, with paths.>

## 3. Review checklist

Answer each with yes or no; a "no" is a finding.

1. <A check a reviewer can answer from the diff.>

## 4. Where it lives

| Thing | File |
|---|---|
| <module, schema, stylesheet, test> | `<path>` |
