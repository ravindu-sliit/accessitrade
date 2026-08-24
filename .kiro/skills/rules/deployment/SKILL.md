---
name: deployment
description: Deployment awareness - pre-deploy checklist, rollback strategy, environment config, migration coordination
user-invocable: false
---

# Deployment

## Pre-Deploy Checklist

Before any deployment:

- [ ] Build passes with no errors or warnings
- [ ] All tests pass
- [ ] Database migrations are included and tested
- [ ] No hardcoded environment-specific values (use env vars)
- [ ] No secrets committed to source
- [ ] Breaking API changes are versioned or backward-compatible
- [ ] Feature flags set correctly for gradual rollout (if applicable)

## Environment Configuration

- Use environment variables for all environment-specific values.
- Never reference `localhost`, hardcoded ports, or dev credentials in committed code.
- Document new env vars needed in PR description.

## Migration Coordination

For schema changes:

1. **Deploy migration first** (additive changes only).
2. **Deploy application code** that uses the new schema.
3. **Clean up** old columns/tables in a follow-up (after confirming no rollback needed).

Never deploy code that depends on a migration that hasn't run yet.

## Rollback Awareness

When writing code, consider:

- Can this change be rolled back without data loss?
- If a migration adds a column, the old code should still work with it present.
- If a migration removes a column, ensure no running code references it.

## Multi-Tenant Deployment

- Proxy API routes to tenant shards — migrations must run on ALL shards.
- Test migration on a single shard before rolling out to all.
- Provisioning service handles per-tenant migration execution.

## Docker

- `docker-compose` files are for local dev only.
- Production uses orchestrated deployment (not compose).
- Ensure `Dockerfile` builds match CI build configuration.
