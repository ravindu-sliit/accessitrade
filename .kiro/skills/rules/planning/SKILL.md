---
name: planning
description: Task planning and decomposition - how to analyze requirements, break down work, sequence steps, and validate before executing
user-invocable: false
---

# Task Planning & Execution

Apply these rules when planning and executing any coding task.

## 1. Understand Before Acting

- Read the user's request fully before responding or making changes.
- Identify the core intent: is this a bug fix, new feature, refactor, or question?
- If the request is ambiguous, infer the most likely intent from context. Ask only when multiple valid interpretations lead to fundamentally different outcomes.
- Check for constraints: target files, frameworks, patterns, or conventions already in use.

## 2. Investigate Before Planning

- Read relevant existing code before proposing changes.
- Check project structure, build tools, test runners, and config files to understand what's available.
- Identify dependencies between the change and other parts of the system.
- For unfamiliar codebases, scan directory structure and key files first.

## 3. Decompose the Task

Break work into discrete, ordered steps:

- **Atomic steps**: each step produces a verifiable result (a file created, a test passing, a build succeeding).
- **Dependency order**: do steps that produce inputs for later steps first.
- **Smallest viable unit**: don't combine unrelated changes into one step.

Example decomposition for "add a new API endpoint":
1. Read existing endpoint patterns (controller, service, DTO conventions)
2. Create the model/entity
3. Create DTOs
4. Create service interface and implementation
5. Create controller
6. Register in DI/DbContext
7. Verify build passes
8. Add/run tests

## 4. Sequence Correctly

- **Read before write**: always read a file before modifying it.
- **Create before reference**: create new files before importing them elsewhere.
- **Build before test**: ensure compilation succeeds before running tests.
- **Test before done**: verify the change works before presenting it as complete.

## 5. Scope Control

- Solve exactly what was asked. Don't add unrequested features, abstractions, or cleanup.
- If a prerequisite fix is needed, state it and do it, but keep it minimal.
- If the task reveals a larger problem, flag it separately rather than expanding scope silently.

## 6. Risk Assessment

Before executing, evaluate:

- **Blast radius**: how many files/systems does this touch?
- **Reversibility**: can this be undone easily?
- **Confidence**: do I have enough information to proceed correctly?

If confidence is low, investigate more before acting. If blast radius is high, outline the plan and confirm before executing.

## 7. Validate the Plan

Before executing a multi-step plan, check:

- Does each step have a clear input and output?
- Are there circular dependencies?
- Does the sequence respect the project's build/test pipeline?
- Will the final result satisfy the original request?

## 8. Adapt When Stuck

- If an approach fails twice, stop and diagnose the root cause.
- Consider whether the failure is in the approach or in a missing prerequisite.
- Try a fundamentally different approach rather than incremental patches.
- If the new approach changes scope or tradeoffs, explain before proceeding.

## 9. Communicate the Plan

For complex tasks (3+ steps or multiple files):

- State the plan briefly before executing.
- Group related steps logically.
- Call out any assumptions or decisions made.
- After completion, summarize what was done in a few sentences.

For simple tasks (single file, obvious change): just do it.
