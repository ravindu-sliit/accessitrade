---
name: performance
description: Performance awareness - N+1 detection, bundle size, indexing, caching decisions
user-invocable: false
---

# Performance

## Backend (.NET + EF Core)

### N+1 Query Detection
- Never access navigation properties in a loop without `.Include()`.
- Use `.Select()` projection to fetch only needed fields for list endpoints.
- Use `.AsNoTracking()` for read-only queries.

```csharp
// Bad: N+1
var invoices = await _context.Invoices.ToListAsync();
foreach (var inv in invoices)
    Console.WriteLine(inv.Customer.Name); // lazy load per iteration

// Good: eager load
var invoices = await _context.Invoices
    .Include(i => i.Customer)
    .AsNoTracking()
    .ToListAsync();
```

### Query Optimization
- Filter in the database, not in memory (apply `.Where()` before `.ToList()`).
- Use pagination for all list endpoints — never return unbounded results.
- Avoid `.ToList()` mid-query; keep as `IQueryable` until final materialization.

### Indexes
Add when a query is slow and the column is in `WHERE`, `ORDER BY`, or `JOIN`:
```csharp
modelBuilder.Entity<Invoice>()
    .HasIndex(i => i.SchoolId);
```

## Frontend

### Bundle Size
- Import only what's needed: `import { Button } from '@/components/ui'` not entire libraries.
- Use dynamic imports (`next/dynamic`, `React.lazy`) for heavy components not needed on initial load.
- Check if a utility already exists in the project before adding a new dependency.

### Rendering
- Avoid re-renders from unstable references (memoize callbacks/objects passed as props when needed).
- Don't fetch data inside components that render in lists.
- Use `key` prop correctly — never use array index for dynamic lists.

### Data Fetching
- Fetch in parallel when requests are independent (`Promise.all`).
- Prefetch data for likely next navigations.
- Cache API responses appropriately (RTK Query / TanStack Query handle this).

## Caching Decision Tree

```
Is the data static/rarely changes?
  → Cache aggressively (long TTL, stale-while-revalidate)

Is it user-specific?
  → Cache per-user, short TTL

Is it tenant-specific shared data?
  → Cache per-tenant, medium TTL, invalidate on write

Is it real-time critical?
  → Don't cache, fetch fresh
```
