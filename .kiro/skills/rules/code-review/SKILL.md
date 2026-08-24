---
name: code-review
description: Automated code review checklist - security, conventions, error handling, spec compliance, before marking work complete
user-invocable: false
---

# Code Review

Run this checklist before presenting any code change as complete.

## Mandatory Checks

### Security
- No hardcoded secrets, tokens, or credentials
- User input is validated and sanitized
- SQL uses parameterized queries (EF Core LINQ, not raw string interpolation)
- Auth endpoints have `[Authorize]` and `[PermissionGuard]`
- Multi-tenant queries filter by allowed tenants

### Error Handling
- Service methods handle exceptions (try-catch with `UnprocessableEntityException`)
- Controllers return appropriate status codes
- Frontend has error boundaries and loading states
- Async operations have error handling

### Conventions
- Naming matches project patterns (PascalCase .NET, camelCase TS)
- Files are in correct directories per project structure
- DTOs follow `*RequestDTO`, `*ResponseDTO`, `*FilterDTO` naming
- Routes use kebab-case
- All timestamps use UTC

### Completeness
- Every acceptance criterion from the spec is addressed
- No TODO comments left without explanation
- DI registration added for new services
- DbSet added for new entities
- Permissions seeded for new modules

### Performance
- No N+1 queries (use `.Include()` or projection)
- List endpoints have pagination
- No unnecessary `.ToList()` before filtering
- Frontend doesn't fetch data in loops

## Review Process

1. Re-read the original request/spec
2. Walk through each changed file against the checklist
3. Run build to verify compilation
4. Run relevant tests
5. Flag any items that fail with the reason
