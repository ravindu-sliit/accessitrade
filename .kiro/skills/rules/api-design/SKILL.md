---
name: api-design
description: API design conventions - endpoint naming, versioning, pagination, error responses, DTO validation, breaking change detection
user-invocable: false
---

# API Design

## Endpoint Naming

```
GET    /api/{module}/{resource}          # List (paginated)
GET    /api/{module}/{resource}/{id}     # Get by ID
POST   /api/{module}/{resource}          # Create
PATCH  /api/{module}/{resource}/{id}     # Update
DELETE /api/{module}/{resource}/{id}     # Soft delete
PATCH  /api/{module}/{resource}/{id}/restore  # Restore
```

- Use kebab-case for multi-word resources: `/api/sales/sale-invoices`
- Group by module: `/api/sales/`, `/api/stock/`, `/api/purchases/`
- No verbs in URLs (use HTTP methods instead)

## Response Format

All responses wrapped in `CommonResponseDTO`:

```json
{
  "status": "success" | "failed",
  "message": "Human-readable message",
  "data": { ... }
}
```

## Pagination

Query params: `?page=0&pageSize=10`

Response shape:
```json
{
  "results": [],
  "pageNumber": 0,
  "pageSize": 10,
  "totalRecords": 100,
  "totalPages": 10
}
```

## Error Responses

| Status | Use Case |
|--------|----------|
| 400 | Malformed request (missing required fields) |
| 401 | Not authenticated |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 422 | Business rule violation |

## DTO Validation

- `RequestDTO`: use `required` keyword for mandatory fields.
- `EditDTO`: all fields nullable (partial update).
- `FilterDTO`: all fields nullable (optional filters).
- Validate at service layer, not controller.
- Return 422 with clear message on validation failure.

## Breaking vs Non-Breaking Changes

### Non-breaking (safe)
- Add new optional field to response
- Add new endpoint
- Add new optional query parameter

### Breaking (requires versioning or coordination)
- Remove or rename a response field
- Change field type
- Remove an endpoint
- Make an optional field required

## Versioning

Use `[ApiVersion("1.0")]` on controllers. When a breaking change is unavoidable:

1. Create new versioned endpoint.
2. Deprecate old endpoint (don't remove immediately).
3. Document migration path.
