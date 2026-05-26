# CLAUDE.md — Recipe Manager Backend

This file is automatically loaded by Claude Code. All rules below are non-negotiable and apply to every session in this repository.

---

## Architecture Rules

- **Layer order:** `API` → `Service` → `Repository` → `Data`. No cross-layer shortcuts.
- **Data access:** Raw SQL via **Dapper only**. Entity Framework is forbidden.
- **Migrations:** Add a new numbered `.sql` file in `src/RecipeManager.Data/Migrations/`. Never modify an applied migration.
- **Constraint logic:** Belongs strictly in the Service layer. Repositories only handle persistence.
- **SQL portability:** ANSI-compliant SQL only — no SQLite-exclusive syntax.

## Commit Discipline (Mandatory)

- **Atomic commits:** Each commit covers one logical unit (e.g., entity, repository interface, service method, test). Never commit an entire feature at once.
- **Test before commit:** Run `dotnet test` and confirm all tests pass before staging files.
- **Pre-commit self-review:** Before every `git add`, verify:
  - No debug code or dead code
  - No unused `using` imports
  - No `// TODO` placeholders
  - No unimplemented methods (stubs are forbidden)
  - Code strictly follows layered architecture
  - Think through edge cases; explain how they could break the app before committing

## Code Quality Rules

- **No placeholders:** Write complete, production-ready code only.
- **No guessing on failures:** When a test or build fails, read the full error log and explain the root cause before touching any file.
- **Defensive design:** Validate inputs at system boundaries. Use descriptive custom domain exceptions (`ConstraintImpossibleException`, `CalorieTargetUnreachableException`, etc.).
- **Dependency check first:** Before installing any NuGet package, search `.csproj` files to verify it is not already available. Always use latest stable versions. Ask for explicit approval before installing new packages.

## Menu Generator Rules

- Use `new System.Random(seed)` — one instance, created once, passed through the entire assembly loop.
- Forbidden inside the selection loop: `Guid.NewGuid()`, `Random.Shared`, `DateTime.Now`, `DateTime.UtcNow`, async calls.
- If constraints make menu generation impossible, throw a descriptive domain exception — never return partial or silent results.

## Agent Accountability

- After every algorithm decision or tuning adjustment, append an entry to `../agents/agent_log.md`.
- Format: date, prompt/trigger, decision made, outcome, tuning adjustment (if any).

## Testing Standards

- Framework: **xUnit** + **FluentAssertions**
- All tests use `// Arrange / Act / Assert` comment blocks.
- Constraint-compliance tests must iterate over all 21 menu slots to verify zero leaks.
- Integration tests use `WebApplicationFactory<Program>` — no mocking the database.
