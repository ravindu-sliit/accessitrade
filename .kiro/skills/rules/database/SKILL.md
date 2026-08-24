---
name: database
description: Database conventions - migrations, schema changes, multi-tenant isolation, seed data, safe change patterns
user-invocable: false
---

# Database

## Migration Workflow

1. Make model changes (add/modify entity, DbSet).
2. Run `dotnet ef migrations add {MigrationName}`.
3. Review generated migration file for correctness.
4. Verify with `dotnet ef database update` (dev only).

Migration naming: `Add{Entity}Table`, `Add{Column}To{Table}`, `Remove{Column}From{Table}`.

Never edit migration files manually.

## Safe Schema Changes

### Additive (safe to deploy immediately)
- Add new table
- Add nullable column
- Add index

### Two-phase (requires coordination)
1. **Phase 1**: Add new column as nullable → deploy → backfill data
2. **Phase 2**: Make column required (if needed) → deploy

### Destructive (high risk — confirm with user)
- Drop table or column
- Rename column (breaks existing queries)
- Change column type

## Multi-Tenant Data Isolation

- Entities with tenant scope inherit `SchoolBaseEntity` (includes `SchoolId`).
- Every query on tenant-scoped data MUST filter by `AllowedSchoolIds`.
- Migrations run per-shard via the proxy provisioning service.
- Never write cross-tenant queries without explicit justification.

## Seed Data

Location: `Data/DbInitializer.cs`

Rules:
- Seed only reference/lookup data and permissions.
- Use `AddOrUpdate` pattern to avoid duplicates on re-run.
- Permission format: `READ:{MODULE}`, `CREATE:{MODULE}`, `EDIT:{MODULE}`, `DELETE:{MODULE}`, `RESTORE:{MODULE}`.

## Indexes

Add indexes when:
- A column is used in `WHERE` clauses frequently.
- A column is used in `ORDER BY` on large tables.
- A foreign key doesn't already have one (EF Core adds these by default).

```csharp
modelBuilder.Entity<Invoice>()
    .HasIndex(i => new { i.SchoolId, i.CreatedAt });
```

## Relationships

- Use `[ForeignKey("NavigationProperty")]` on the FK property.
- Navigation properties are `virtual` and nullable.
- Configure cascade behavior explicitly for non-obvious relationships.
- Prefer `Restrict` over `Cascade` for delete behavior on important entities.
