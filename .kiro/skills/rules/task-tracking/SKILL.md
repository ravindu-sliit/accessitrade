---
name: task-tracking
description: Autonomous SDLC task management - spec-to-deploy pipeline with atomic todo tracking, subagent delegation, minimal human input
user-invocable: false
---

# Task Tracking — Autonomous SDLC

## Overview

For large projects, run the full SDLC autonomously. The agent reads specs, plans tasks, implements, tests, reviews, and commits — only pausing for human input on high-risk decisions.

## Task File

```
docs/tasks/current.md    # Always reflects current state of work
```

## Autonomous SDLC Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│  1. SPEC PHASE        → spec-generator subagent             │
│  2. PLAN PHASE        → researcher subagent                 │
│  3. IMPLEMENT PHASE   → executor subagent (per task)        │
│  4. VERIFY PHASE      → build + test (executor)             │
│  5. REVIEW PHASE      → reviewer subagent                   │
│  6. COMMIT PHASE      → pilot/project-runner (git)          │
│  7. REPEAT            → next task group until done          │
└─────────────────────────────────────────────────────────────┘
```

## Phase Details

### Phase 1: Spec Generation
1. Check `docs/spec/raw/` for user-provided documents.
2. Delegate to **spec-generator**: expand raw docs into structured specs in `docs/spec/generated/`.
3. If no raw docs exist, ask user for requirements (ONLY human touchpoint for clear requests).

### Phase 2: Planning
1. Delegate to **researcher**: read generated specs + existing codebase, identify all changes needed.
2. Create `docs/tasks/current.md` with atomic tasks grouped by phase.
3. Identify dependencies between tasks and order accordingly.

### Phase 3: Implementation
1. For each task (or batch of independent tasks):
   - Delegate to **executor** with specific instructions and file references.
   - Executor implements and runs build.
2. Update task list: mark completed, add new tasks if discovered.

### Phase 4: Verification
1. After each implementation batch, run full build.
2. Run relevant tests.
3. If failures: delegate fix to executor, update task list.

### Phase 5: Review
1. After a logical group of tasks is complete, delegate to **reviewer**.
2. Reviewer checks against code-review skill checklist and spec acceptance criteria.
3. If issues found: add fix tasks to list, loop back to Phase 3.

### Phase 6: Commit
1. Stage relevant files.
2. Commit with conventional message.
3. Move to next task group.

### Phase 7: Completion
1. All tasks checked off.
2. Final build + test pass.
3. Final review pass.
4. Create PR (if on a feature branch).
5. Mark task file as completed.

## Task File Format

```markdown
# Task: {Feature Name}

## Source
- Spec: docs/spec/generated/{feature}.md
- Raw: docs/spec/raw/{source-file}

## Status: IN_PROGRESS | BLOCKED | COMPLETE

## Phase: SPEC | PLAN | IMPLEMENT | VERIFY | REVIEW | COMMIT

## Tasks

### Data Layer
- [x] Create model `Models/Sales/Invoice.cs`
- [x] Add DbSet to ApplicationDbContext
- [x] Create migration

### Service Layer
- [x] Create `DTOs/Sales/InvoiceDTOs.cs`
- [ ] Create `Services/Sales/IInvoiceService.cs` ← CURRENT
- [ ] Create `Services/Sales/InvoiceService.cs`
- [ ] Register in Program.cs

### API Layer
- [ ] Create `Controllers/Sales/InvoiceController.cs`
- [ ] Seed permissions in DbInitializer

### Testing
- [ ] Service unit tests
- [ ] API integration tests

### Verification
- [ ] Build passes
- [ ] All tests pass
- [ ] Review checklist passes

## Decisions
- {Decision made and why}

## Blockers
- {Anything requiring human input}
```

## Rules

### Minimize Human Engagement
- **DO NOT ask** for confirmation on standard implementation decisions (naming, structure, patterns).
- **DO NOT ask** which file to create — follow project conventions.
- **DO NOT ask** how to implement — follow specs and existing patterns.
- **DO ask** only when:
  - Spec is contradictory or impossible to implement.
  - A destructive action is needed (drop table, force push).
  - Business logic is ambiguous with no existing pattern to follow.
  - Multiple valid approaches exist with significant tradeoffs.

### Always Use Subagents
- **researcher**: for investigation and planning
- **spec-generator**: for spec expansion
- **executor**: for implementation (one task or batch at a time)
- **reviewer**: for quality validation

The orchestrating agent (pilot/project-runner) NEVER implements directly. It plans, delegates, tracks, and commits.

### Always Update Task File
- Mark tasks done immediately after executor confirms success.
- Add new tasks when discovered during implementation.
- Update `## Phase` to reflect current pipeline stage.
- Update `## Status` when blocked or complete.
- Log decisions in `## Decisions` section.

### Batch Execution
- Group independent tasks and delegate to executor in parallel when possible.
- Sequential tasks (those with dependencies) execute one at a time.
- After each batch: verify build, update task file, proceed.

### Recovery
- If executor fails a task twice: stop, diagnose root cause, update plan.
- If reviewer rejects: add fix tasks, re-enter implement phase.
- If build breaks: prioritize fix before continuing new tasks.
- Log all failures and fixes in `## Decisions`.
