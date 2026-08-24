---
name: frontend
description: Frontend patterns - component decomposition, state management decisions, form handling, loading/error states
user-invocable: false
---

# Frontend Patterns

## Component Decomposition

Split a component when:
- It exceeds ~150 lines.
- It has distinct visual/logical sections.
- A section is reused elsewhere.
- It manages multiple unrelated pieces of state.

Keep together when:
- Splitting would require prop drilling 3+ levels.
- The logic is tightly coupled and only used here.

## State Management Decision Tree

```
Is the state used by one component only?
  → useState / local state

Is it shared between siblings/cousins?
  → Lift to nearest common parent, or use context

Is it app-wide or persisted across routes?
  → Client App: Redux Toolkit (store/slices/)
  → Admin App: Zustand (stores/)

Is it server data (fetched from API)?
  → Client App: RTK Query or service + useEffect
  → Admin App: TanStack Query
```

## Form Handling

- Use controlled components with local state for simple forms.
- For complex forms (many fields, validation): use a form library if one exists in the project.
- Validate on submit, show inline errors per field.
- Disable submit button during API call, show loading indicator.
- On success: redirect or show success toast. On error: show error message, keep form data.

## Loading & Error States

Every data-fetching component must handle:

```tsx
if (isLoading) return <Skeleton /> // or spinner
if (error) return <ErrorMessage error={error} />
return <ActualContent data={data} />
```

- Use skeleton loaders for layout-stable loading states.
- Error states should offer a retry action when possible.
- Empty states should guide the user ("No invoices yet. Create one?").

## API Integration

- Service files handle API calls (one file per domain).
- Components call services, never `fetch` directly.
- Handle loading, success, and error in the component or hook.
- Optimistic updates only for low-risk actions (toggling, reordering).

## File Organization

```
# Client App (Next.js)
src/
├── components/{domain}/     # Domain-specific components
├── components/ui/           # Shared UI primitives
├── services/{domain}/       # API service functions
├── store/slices/            # Redux slices
├── hooks/                   # Shared custom hooks
├── utils/                   # Pure utility functions
└── interfaces/              # TypeScript interfaces

# Admin App (Vite)
src/
├── components/{domain}/
├── components/ui/
├── services/{domain}/
├── stores/                  # Zustand stores
├── hooks/
├── utils/
└── types/
```
