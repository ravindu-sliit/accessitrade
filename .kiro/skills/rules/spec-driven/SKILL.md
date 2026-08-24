---
name: spec-driven
description: Generate expanded implementation specs in docs/spec/generated from raw user-provided documents in docs/spec/raw
user-invocable: false
---

# Spec-Driven Development

## Overview

Users place raw requirement documents (briefs, notes, screenshots, conversations, rough specs) in `docs/spec/raw/`. The agent generates structured, implementation-ready specification files in `docs/spec/generated/`.

## Directory Structure

```
docs/spec/
├── raw/                    # User-provided input (DO NOT modify)
│   ├── *.md, *.txt, *.pdf # Briefs, notes, requirements
│   └── ...
└── generated/              # Agent-generated expanded specs
    ├── {feature}.md        # Full feature spec
    ├── {feature}-api.md    # API contract spec
    ├── {feature}-data.md   # Data model spec
    └── {feature}-ui.md     # UI spec (if applicable)
```

## Rules

- Never modify files in `docs/spec/raw/`.
- Always read ALL files in `docs/spec/raw/` relevant to the feature before generating.
- Read existing codebase patterns (models, services, controllers, components) to align generated specs with project conventions.
- Output goes exclusively to `docs/spec/generated/`.
- If a generated spec already exists, update it rather than duplicating.

## Generation Process

1. **Read** all relevant raw documents in `docs/spec/raw/`.
2. **Analyze** the existing codebase for conventions, naming, patterns, and tech stack.
3. **Expand** raw requirements into structured specs covering every implementation detail.
4. **Write** generated spec files to `docs/spec/generated/`.

## Generated Spec Format

Each generated spec file must include:

### Feature Spec (`{feature}.md`)

```markdown
# {Feature Name}

## Summary
One-paragraph description of what this feature does.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Business Rules
- Rule 1: description
- Rule 2: description

## Edge Cases
- Case 1: expected behavior
- Case 2: expected behavior

## Dependencies
- Depends on: {other features/modules}

## Out of Scope
- Items explicitly excluded
```

### API Spec (`{feature}-api.md`)

```markdown
# {Feature} API

## Endpoints

### POST /api/{resource}
- **Auth**: Required
- **Permissions**: CREATE:{MODULE}
- **Request Body**:
  ```json
  { "field": "type" }
  ```
- **Response 200**:
  ```json
  { "status": "success", "data": {} }
  ```
- **Errors**: 422 (validation), 403 (forbidden)
```

### Data Spec (`{feature}-data.md`)

```markdown
# {Feature} Data Model

## Entities

### {EntityName}
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| name  | string | yes | maxLength: 100 |

## Relationships
- {Entity} belongs to {OtherEntity}

## Indexes
- Unique: (field1, field2)

## Migrations
- Description of schema changes needed
```

### UI Spec (`{feature}-ui.md`) — only if feature has frontend

```markdown
# {Feature} UI

## Pages/Routes
- /dashboard/{feature} — list view
- /dashboard/{feature}/[id] — detail view

## Components
- {ComponentName}: purpose, props, behavior

## State Management
- Store/slice changes needed

## User Flows
1. User navigates to...
2. User clicks...
3. System responds with...
```

## Quality Checks

Before finalizing a generated spec:

- Every field/endpoint/component mentioned in raw docs is accounted for.
- Naming follows existing project conventions.
- No ambiguity — if the raw doc is vague, make a decision and document it under "Assumptions".
- Acceptance criteria are testable (each can be verified by a test or manual check).
- Cross-reference with existing specs in `docs/spec/generated/` to avoid conflicts.

## Assumptions Section

When raw documents are incomplete, add an `## Assumptions` section listing decisions made and rationale. Flag high-risk assumptions that need user confirmation.
