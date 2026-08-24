---
name: debugging
description: Systematic debugging - reproduce, isolate, fix, verify. Common failure modes per service layer.
user-invocable: false
---

# Debugging

## Process

1. **Reproduce**: confirm the exact error (message, stack trace, steps).
2. **Isolate**: narrow down to the specific layer/file/line.
3. **Hypothesize**: form a theory about the root cause.
4. **Fix**: make the minimal change that addresses the root cause.
5. **Verify**: confirm the fix works and doesn't break other things.

## Isolation Strategy

- Start from the error message and trace backwards.
- Check the layer where the error surfaces, then the layer that feeds it.
- Use binary search: if unsure which change broke things, bisect recent changes.

## Common Failure Modes

### .NET Backend
| Symptom | Likely Cause |
|---------|-------------|
| 500 on startup | Missing DI registration, bad connection string |
| 401 on all requests | JWT config mismatch, expired token |
| 403 on specific endpoint | Missing permission in seed, wrong `[PermissionGuard]` |
| Null reference in service | Missing `.Include()` for navigation property |
| Empty list response | Tenant filter excluding data, `IsDeleted` not accounted for |
| Migration failure | Model mismatch, manual migration edit |

### Next.js Frontend
| Symptom | Likely Cause |
|---------|-------------|
| Hydration mismatch | Browser-only API in server component, date formatting |
| 404 on API call | Wrong base URL, missing proxy config |
| Infinite re-render | Dependency array issue in useEffect, unstable reference |
| Build failure | Import from server component in client component |
| Blank page | Unhandled promise rejection, missing error boundary |

### Multi-Tenant / Proxy
| Symptom | Likely Cause |
|---------|-------------|
| Wrong tenant data | Shard routing misconfigured |
| Connection refused | Tenant DB not provisioned, server pool exhausted |
| Intermittent failures | Connection pool exhaustion, timeout on shard lookup |

## When Stuck

- If two attempts at the same approach fail, step back and re-diagnose.
- Check if the problem is in your code or in the environment (deps, config, DB state).
- Read error messages literally — don't assume what they mean.
- Check recent changes that could have introduced the issue.
