# Recipe Manager — Backend

ASP.NET Core 8 Web API implementing the Recipe Manager & Weekly Menu Planner backend.

---

## Architecture

The codebase follows a strict **Layered Architecture** with one-directional dependency flow:

```
API  →  Service  →  Repository  →  Data
```

| Project | Role |
|---|---|
| `RecipeManager.API` | HTTP controllers, request/response DTOs, middleware |
| `RecipeManager.Service` | Business logic, constraint-menu-generator engine, domain exceptions |
| `RecipeManager.Repository` | Data access via Dapper (raw SQL only — no EF Core) |
| `RecipeManager.Data` | Entities, value objects, DbUp migration scripts |
| `RecipeManager.Tests.Unit` | xUnit + FluentAssertions — service-layer and algorithm tests |
| `RecipeManager.Tests.Integration` | xUnit + WebApplicationFactory — full HTTP pipeline tests |

---

## Stack

- **.NET 8** — runtime
- **Dapper** — micro-ORM for raw SQL (EF Core is forbidden by architecture rules)
- **DbUp** — ordered `.sql` migration runner
- **SQLite** — development database
- **SQL Server** — production target (ANSI-compliant SQL throughout)
- **xUnit** — test framework
- **FluentAssertions** — assertion library

---

## Getting Started

### Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

### Build

```bash
dotnet build
```

### Run tests

```bash
dotnet test
```

### Run the API

```bash
dotnet run --project src/RecipeManager.API
```

The API starts on `https://localhost:5001` by default.

---

## Database Migrations

Migrations live in `src/RecipeManager.Data/Migrations/` as ordered `.sql` files:

```
001_InitialSchema.sql
002_<next-feature>.sql
...
```

DbUp runs all pending scripts in ascending filename order on application startup.
**Never modify an already-applied migration** — always add a new numbered script.

---

## Core Feature: Constraint-Menu Generator

The `MenuGeneratorService` in the Service layer produces a deterministic 7-day meal plan (21 slots) using a seed-based selection loop. For any identical combination of recipe pool, constraints, and `Seed` integer the output is guaranteed to be 100% identical.

Key rules (enforced by the `constraint-menu-generator` skill):
- `new System.Random(seed)` — single instance, created once, used throughout the loop
- No `Guid.NewGuid()`, `Random.Shared`, or clock dependencies inside the selection loop
- Constraint violations throw descriptive domain exceptions (`ConstraintImpossibleException`, `CalorieTargetUnreachableException`)

See `../../skills/constraint-menu-generator/SKILL.md` for the full agent skill specification.

---

## Development Guardrails

- **Atomic commits:** one logical unit per commit; run `dotnet test` before every commit
- **Pre-commit self-review:** no debug code, unused imports, or `// TODO` placeholders
- **No placeholder implementations:** every method must be production-ready before commit
- **SQL portability:** ANSI-compliant SQL only — no SQLite-exclusive syntax
- **Agent log:** document every algorithm decision in `../../agents/agent_log.md`

---

## Project Structure

```
recipe-manager.backend/
├── RecipeManager.sln
├── src/
│   ├── RecipeManager.API/
│   ├── RecipeManager.Service/
│   ├── RecipeManager.Repository/
│   └── RecipeManager.Data/
│       └── Migrations/
│           └── 001_InitialSchema.sql
└── tests/
    ├── RecipeManager.Tests.Unit/
    └── RecipeManager.Tests.Integration/
```
