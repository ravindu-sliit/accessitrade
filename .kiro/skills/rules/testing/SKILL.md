---
name: testing
description: Testing strategy - when to write tests, what to test, conventions per project, mock patterns for multi-tenant context
user-invocable: false
---

# Testing

## When to Write Tests

- Every new feature gets tests covering its acceptance criteria.
- Every bug fix gets a regression test proving the fix.
- Refactors must have passing tests before and after.

## Test Frameworks

| Project | Framework | Location |
|---------|-----------|----------|
| saas-erpx-client-api | xUnit | Tests/ alongside project or separate test project |
| saas-erpx-admin-portal-api | xUnit | Tests/ |
| saas-erpx-client-app | Jest | `__tests__/` or `*.test.ts(x)` co-located |
| saas-erpx-admin-portal-app | Vitest | `__tests__/` or `*.test.ts(x)` co-located |

## What to Test

### Backend (.NET)
- **Service layer**: business logic, calculations, validations, edge cases
- **Controller layer**: only if complex mapping/authorization logic exists
- **Integration**: API endpoint returns correct response for valid/invalid input

### Frontend (React)
- **Components**: render correctly with props, handle user interactions
- **Hooks**: return correct state, handle loading/error
- **Utils**: pure functions with edge cases

## Test Naming

```csharp
// .NET: Method_Scenario_ExpectedResult
public async Task CreateInvoice_WithValidData_ReturnsInvoiceResponse()
public async Task CreateInvoice_WithMissingAmount_ThrowsValidationError()
```

```typescript
// TS: describe block + it/test with plain language
describe('InvoiceService', () => {
  it('creates invoice with valid data', async () => {})
  it('throws when amount is missing', async () => {})
})
```

## Mock Patterns

### .NET Multi-Tenant
```csharp
// Mock HttpContextAccessor for tenant context
var httpContext = new DefaultHttpContext();
httpContext.User = new ClaimsPrincipal(new ClaimsIdentity(new[] {
    new Claim("user_id", "1")
}));
httpContext.Items["AllowedSchoolIds"] = new List<int> { 1, 2 };
var accessor = Mock.Of<IHttpContextAccessor>(a => a.HttpContext == httpContext);
```

### Frontend API Mocks
```typescript
// Mock service calls, not fetch directly
jest.mock('@/services/sales/invoice.service', () => ({
  getInvoices: jest.fn().mockResolvedValue({ results: [], totalRecords: 0 }),
}))
```

## Minimum Coverage Per Change

- New service method: at least happy path + one error case
- New endpoint: request validation + success + auth failure
- New component: renders without crash + key interaction
- Bug fix: test that reproduces the bug
