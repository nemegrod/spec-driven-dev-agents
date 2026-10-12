# Solution Architecture Document

**Owner:** Solution Architect

This document describes the current solution: context, scope, constraints, architecture and risks. It carries no history; every change is recorded in `docs/change_log.md`. Requirements live in `docs/req.md`, questions in `docs/questions.md`, facts in `docs/facts.md` and architectural decisions in `docs/decision_log.md`; this document cites them by ID and never restates them. Item formats: the `spec-authoring` skill, Section 3.

## 1. Context and Problem

_The verified current state, the problem to solve and why it matters. Cite facts by ID._

## 2. Stakeholders and Outcomes

| Stakeholder | Need | Desired outcome | Source |
|---|---|---|---|

## 3. Scope

### Goals

| ID | Goal |
|---|---|

### Non-goals

| ID | Non-goal | Why |
|---|---|---|

### Backlog

| ID | Deferred outcome | Revisit when |
|---|---|---|

### System Boundary

_What is inside and outside the system, and the external actors._

## 4. Requirements

The requirements are the FR and NFR items in `docs/req.md`. This section names their groups and the constraints they rest on.

### Constraints

| ID | Constraint | Source | Consequence |
|---|---|---|---|

## 5. Assumptions and Open Questions

### Assumptions

| ID | Assumption | Evidence | Consequence if false |
|---|---|---|---|

### Open Questions

The open questions are the OQ items in `docs/questions.md` with `Status: open`.

## 6. Solution Architecture

### System Context

_Actors, external systems, trust boundaries and the system's responsibilities, with one Mermaid diagram and prose that stands without it._

### Components

| Component | Responsibility | Satisfies | Dependencies |
|---|---|---|---|

### Key Interactions and Data Flows

_The important success paths, alternate paths, failure scenarios and conceptual data movement. The detailed flows are in `docs/flows/`._

## 7. Integrations

| Integration | Purpose | Conceptual contract | Failure behavior | Owner |
|---|---|---|---|---|

## 8. Security, Privacy, and Trust

_Trust boundaries, data classification, authorization expectations, sensitive-data handling, audit needs and the material threats derived from the requirements._

## 9. Key Architectural Decisions

The decisions are the AD items in `docs/decision_log.md`. This table lists the active ones in one line each.

| Decision | Summary |
|---|---|

## 10. Requirement Traceability

Traceability lives in `docs/req.md`: each requirement's `Design:` line names the LLD sections and design decisions that satisfy it, and its `Verification:` line names how it is verified.

## 11. Risks and Technical Debt

### Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|

### Technical debt

| ID | Debt | Impact | Planned removal |
|---|---|---|---|
