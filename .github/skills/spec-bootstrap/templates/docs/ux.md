# UX Specification

**Owner:** Design/UX Agent

This document describes the current user interface: design direction, structure, every surface and the data each view needs. It carries no history; every change is recorded in `docs/change_log.md`. It cites requirements by ID and LLD interfaces by section, and never restates them. Clarifications are the C items in `docs/questions.md`. Item formats: the `spec-authoring` skill, Section 3.

## 1. Design Direction

### 1.1 Brief

_Who uses the product, for what, and what each surface must communicate._

### 1.2 Visual language

_Tokens for colour, typography, shape and elevation; density; motion. One table per group, with the value and the use of each token._

### 1.3 Design system

_The component library and how it is themed to the tokens. The technical integration is the Software Architect's decision and lives in the LLD._

## 2. Information Architecture

### 2.1 Structure

_The surfaces and how they nest: navigation, routes, dialogs and panels._

### 2.2 Navigation and shared state

_What state the surfaces share, where it lives and what survives a reload._

### 2.3 Layout

_The layout modes, the supported widths and the breakpoints._

### 2.4 Shared states

_How every surface shows empty, loading, failed, partial and updating states._

## 3. Surfaces

_One subsection per surface (3.1, 3.2, …). Each interface element is a UX item with its own ID: what it shows, how it behaves, every state, and the requirement it serves._

## 4. Shared Components

_Components used by more than one surface, specified once._

## 5. Data Needs per View

Each row is one data need of one view and names the LLD interface that supplies it.

| ID | View | Data | Supplied by |
|---|---|---|---|

## 6. Open Items

The open clarifications are the C items in `docs/questions.md` with `Status: open`.
