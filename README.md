# Agentic Engineering Project — Recipe Manager & Weekly Menu Planner

[![Backend CI](https://github.com/fragui/agentic-engineering-project/actions/workflows/backend-ci.yml/badge.svg)](https://github.com/fragui/agentic-engineering-project/actions/workflows/backend-ci.yml)
[![Frontend CI](https://github.com/fragui/agentic-engineering-project/actions/workflows/frontend-ci.yml/badge.svg)](https://github.com/fragui/agentic-engineering-project/actions/workflows/frontend-ci.yml)

A full-stack Recipe Manager and Weekly Menu Planner built as a demonstration of **agentic software engineering** — where an AI agent (Claude Code) drives the full development lifecycle: architecture, implementation, testing, constraint algorithm design, and CI setup, guided by a PRD and an agent accountability framework.

---

## Demo

<video src="demo%20module%202.mp4" controls width="100%"></video>

---

## Features

- **Recipe CRUD** — create, view, edit, and delete recipes with step-by-step instructions
- **Step-based recipe structure** — each step captures culinary actions, scoped ingredients with quantities and units, optional duration, and free-text notes
- **Constraint-based menu generator** — produces a deterministic 7-day meal plan (21 slots) given calorie/macro targets, exclusion tags, and a reproducibility seed
- **Grocery list consolidation** — aggregates all menu ingredients, summing compatible units and listing incompatible ones as separate line items
- **Dietary tagging** — GlutenFree, HighProtein, Vegetarian, Vegan, Breakfast, LowCarb, DairyFree
- **20 seeded recipes** — diverse protein types and meal categories with realistic nutritional data

---

## Stack

| Layer | Technology |
|---|---|
| API | ASP.NET Core 8, Serilog |
| Business logic | C# service layer, seed-based deterministic algorithm |
| Data access | Dapper (raw SQL — no EF Core), DbUp migrations, SQLite |
| Frontend | React 19, TypeScript (strict), Vite |
| Testing (backend) | xUnit, FluentAssertions, WebApplicationFactory |
| Testing (frontend) | Vitest, React Testing Library |
| CI | GitHub Actions |

---

## Repository Structure

```
agentic-engineering-project/
├── .github/
│   └── workflows/
│       ├── backend-ci.yml       # dotnet restore → build → test (23 tests)
│       └── frontend-ci.yml      # npm ci → vitest run (37 tests)
│
├── recipe-manager.backend/      # ASP.NET Core 8 Web API
│   ├── src/
│   │   ├── RecipeManager.API/          # Controllers, middleware, DTOs
│   │   ├── RecipeManager.Service/      # Business logic, menu generator
│   │   ├── RecipeManager.Repository/   # Dapper repositories
│   │   └── RecipeManager.Data/         # Entities, DbUp SQL migrations
│   └── tests/
│       ├── RecipeManager.Tests.Unit/        # Service-layer unit tests
│       └── RecipeManager.Tests.Integration/ # Full HTTP pipeline tests
│
├── recipe-manager.frontend/     # React + TypeScript + Vite SPA
│   └── src/
│       ├── api/                 # Typed API client
│       ├── components/          # Shared UI components
│       ├── features/
│       │   ├── recipes/         # RecipeList, RecipeDetail, RecipeForm
│       │   ├── menu/            # ConstraintForm, MenuCalendar
│       │   └── grocery/         # GroceryList
│       └── types/               # Shared TypeScript interfaces
│
├── agents/
│   └── agent_log.md             # Chronological agent decision log
├── skills/
│   └── constraint-menu-generator/
│       └── SKILL.md             # Agent skill descriptor for the menu engine
├── AGENTS.md                    # Agent rules and collaboration contract
└── PRD.md                       # Product Requirements Document
```

---

## Getting Started

### Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Node.js 22](https://nodejs.org/)

### Backend

```bash
cd recipe-manager.backend

# Restore and run
dotnet restore RecipeManager.sln
dotnet run --project src/RecipeManager.API
# API available at http://localhost:5141
```

The database is created automatically on first run via DbUp. The seed migration loads 20 recipes.

### Frontend

```bash
cd recipe-manager.frontend

npm install
npm run dev
# App available at http://localhost:5173
```

The frontend proxies API calls to `http://localhost:5141` by default (configurable via `VITE_API_URL`).

---

## Running Tests

### Backend — 23 tests (14 unit + 9 integration)

```bash
cd recipe-manager.backend
dotnet test RecipeManager.sln
```

Integration tests use an isolated in-memory SQLite database via `WebApplicationFactory` — no external services required.

### Frontend — 37 tests across 6 test files

```bash
cd recipe-manager.frontend
npm test
```

---

## Architecture Highlights

### Backend — Layered, one-directional dependency flow

```
API  →  Service  →  Repository  →  Data
```

- **No EF Core** — Dapper only, with raw ANSI-compliant SQL
- **DbUp** — numbered `.sql` migration scripts as embedded resources; never modify an applied migration
- **Deterministic menu algorithm** — `MenuGeneratorService` uses `new System.Random(seed)`, one instance per generation call; no `Guid.NewGuid()`, `Random.Shared`, or clock access inside the selection loop

### Frontend — Feature-based structure

- TypeScript strict mode, no `any`
- Controlled `StepDraft[]` form array for dynamic step add/remove/reorder
- API client parameterised by `VITE_API_URL` for environment flexibility

---

## Agentic Development

This project was built using **Claude Code** following the agentic engineering workflow defined in [`AGENTS.md`](AGENTS.md):

- [`PRD.md`](PRD.md) — the source of truth for all requirements
- [`agents/agent_log.md`](agents/agent_log.md) — chronological record of every significant agent decision, tuning adjustment, and outcome
- [`skills/constraint-menu-generator/SKILL.md`](skills/constraint-menu-generator/SKILL.md) — the skill descriptor that teaches the agent how to design and test the deterministic menu engine

All algorithm decisions, bug diagnoses, and architectural trade-offs are traceable in the agent log.
