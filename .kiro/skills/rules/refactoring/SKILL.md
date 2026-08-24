---
name: refactoring
description: Safe refactoring - prerequisites, extract patterns, when refactoring is justified vs premature
user-invocable: false
---

# Refactoring

## Prerequisites

Before refactoring:
1. Existing tests pass (or write them first).
2. Clear goal: what improves after the refactor?
3. Build passes before and after each step.

## When to Refactor

- Duplicated logic across 3+ places.
- A function/method exceeds ~50 lines with multiple responsibilities.
- A change requires modifying the same pattern in many files (extract shared utility).
- The current structure makes the requested feature unreasonably hard to add.

## When NOT to Refactor

- Code works and isn't being modified.
- "It could be cleaner" but no current task requires it.
- During a bug fix (fix first, refactor separately if needed).
- Without tests covering the code being changed.

## Safe Refactoring Steps

1. Ensure tests exist for the code being changed.
2. Make one structural change at a time.
3. Verify build + tests after each change.
4. Commit after each successful step.

## Common Extractions

### Extract Method/Function
When a block of code does one identifiable thing inside a larger function.

### Extract Service/Hook
When logic is reused across multiple components/controllers.

### Extract Constant
When magic values appear in multiple places.

### Extract Component
When JSX block is self-contained with its own state/logic.

## Refactoring Scope

- Keep refactors in separate commits from feature work.
- If a refactor is needed to enable a feature, do it first as a preparatory commit.
- Never mix refactoring with behavior changes in the same commit.
