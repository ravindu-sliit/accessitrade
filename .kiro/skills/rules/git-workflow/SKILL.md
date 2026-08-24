---
name: git-workflow
description: Git conventions - branch naming, commit messages, when to commit, PR generation from task list
user-invocable: false
---

# Git Workflow

## Branch Naming

```
feat/{feature-name}       # New feature
fix/{bug-description}     # Bug fix
refactor/{scope}          # Refactoring
chore/{task}              # Maintenance, deps, config
```

Use kebab-case. Keep under 50 chars.

## Commit Messages

Format: `type(scope): description`

```
feat(sales): add invoice PDF generation
fix(stock): correct quantity calculation on transfer
refactor(auth): extract token validation to middleware
chore(deps): update next.js to 15.1
```

Types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`
Scope: the domain or module affected.

## When to Commit

- After each logical unit of work that builds successfully.
- Align with task list items — one commit per completed task or group of related tasks.
- Never commit broken code.

## Commit Workflow

1. Verify build passes.
2. Stage only relevant files (`git add <specific files>`).
3. Check for accidental secret files before committing.
4. Write commit message following the format above.

## PR Creation

When all tasks are complete:

1. Push branch with `git push -u origin {branch-name}`.
2. Create PR using `gh pr create`.
3. Title: same as the main commit message or task summary (under 70 chars).
4. Description: generated from `docs/tasks/current.md` — list what was done, what was tested, any notes.

## PR Description Template

```markdown
## Summary
{One-line description from task context}

## Changes
- {List of completed task items}

## Testing
- {How it was verified: build, tests, manual check}

## Notes
- {Any assumptions, deviations, or follow-ups}
```
