# CLAUDE.md — Recipe Manager Frontend

This file is automatically loaded by Claude Code. All rules below are non-negotiable and apply to every session in this repository.

---

## Architecture Rules

- **Feature-based structure:** All domain logic lives under `src/features/<feature-name>/`.
- **Shared code:** Cross-feature components go in `src/components/`, hooks in `src/hooks/`, API clients in `src/api/`, TypeScript types in `src/types/`.
- **Step-based recipe form:** Recipe creation must use a dynamic form array (add / remove / reorder steps). Each step binds its own ingredients; ingredients must also auto-populate the master recipe ingredient list.

## Commit Discipline (Mandatory)

- **Atomic commits:** Each commit covers one logical unit (e.g., one component, one API hook, one feature slice). Never commit an entire feature at once.
- **Test before commit:** Run `npm test` and confirm all tests pass before staging files.
- **Pre-commit self-review:** Before every `git add`, verify:
  - No debug `console.log` calls
  - No unused imports
  - No `// TODO` placeholders
  - No unimplemented component stubs
  - Think through edge cases; explain how they could break the UI before committing

## Code Quality Rules

- **TypeScript strict mode:** No `any` types. Define explicit interfaces in `src/types/`.
- **No placeholders:** Write complete, production-ready components only.
- **No guessing on failures:** When a test or build fails, read the full error output and explain the root cause before modifying files.
- **Dependency check first:** Before installing any npm package, check `package.json` to verify it is not already available. Always use latest stable versions. Ask for explicit approval before installing new packages.

## Testing Standards

- Framework: **Vitest** + **React Testing Library** + **@testing-library/jest-dom**
- Test files live alongside the component they test: `MyComponent.test.tsx`
- Tests must validate UI state, form constraints, and calendar rendering as specified in the PRD.
- All tests use `// Arrange / Act / Assert` comment structure.

## Agent Accountability

- After every significant UI decision or constraint implementation, append an entry to `../agents/agent_log.md`.
- Format: date, prompt/trigger, decision made, outcome.
