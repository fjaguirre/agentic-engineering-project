# AGENTS.md - System Instructions

## Application Domain & MVP Scope

- **Product:** Recipe Manager & Weekly Menu Planner.
- **Core Engine:** Recipe CRUD + Deterministic constraint-based menu generation algorithm.
- **MVP Goal:** Tag dietary constraints, generate reproducible 7-day menus, and compile a consolidated grocery list.

## Stack & Architecture

- **Root Layout:** Dual independent repositories/directories (Backend & Frontend).
- **Backend (.NET 8+):** Layered Architecture (`API` -> `Service` -> `Repository` -> `Data`).
- **Data Access:** Raw SQL via **Dapper** (Entity Framework is forbidden).
- **Migration Strategy:** **DbUp** running raw, ordered `.sql` script files.
- **Databases:** SQLite for development; architected for future SQL Server migration.
- **Frontend:** **React** powered by **Vite** and **TypeScript** (Feature-based structure).

## Testing Strategy & Tools

- **Backend Unit Tests (xUnit + FluentAssertions):** Focus on constraint enforcement, seed/random reproducibility, and menu assembly loops.
- **Backend Integration Tests (xUnit + Microsoft.AspNetCore.Mvc.Testing):** Cover the full pipeline from recipe creation to final menu/grocery list export.
- **Frontend Tests (Vitest):** Validate UI state, form constraints, and calendar rendering.
- **CI/CD:** Every push must pass all tests in the pipeline before merging.

## Development Guardrails

- **Algorithmic Determinism:** The menu generator must produce reproducible output for the same inputs/seeds. Avoid unseeded randomness in assembly loops.
- **SQL Portability:** Write ANSI-compliant SQL. Avoid database-exclusive extensions.
- **Separation of Concerns:** Algorithmic constraint-checking logic belongs strictly in the Service layer. Repositories only handle data persistence.
- **Agent Logging:** Document key prompts and tuning rules used for the generation engine in an `agent_log.md` file during development.
- **Atomic Commits:** Do not implement the entire feature at once. Divide the work into small, logically delimited steps (e.g., entity creation, repository interface, service logic). Run tests and make a Git commit for each step.
- **Pre-Commit Code Review:** Before staging files or running a commit, self-review the generated diff. Verify that no debug code, unused imports, or placeholder comments (`// TODO`) are left behind, and confirm the code strictly aligns with our layered architecture. Think on edge cases and explain how it would break the app and suggest solutions, so them can be fixed.
- **No Placeholders:** Write complete, production-ready code. Do not leave methods unimplemented or hallucinate uninstalled dependencies.
- **Root-Cause Analysis:** If a test or build fails, do not guess fixes iteratively. Read the full error log, analyze the root cause, and explain it before modifying files.
- **Defensive Design:** Implement robust validation and descriptive custom exceptions. If constraints make menu generation impossible, fail gracefully with clear business diagnostics.
- **Dependency Management:** Before installing any new npm or NuGet package, search the workspace (`package.json` or `.csproj`) to verify it is not already available. Always use the latest stable versions.
- **Explicit Approval for Packages:** Do not install new external libraries or packages without explicitly asking for permission and explaining why the native stack (or current dependencies) cannot fulfill the requirement.
