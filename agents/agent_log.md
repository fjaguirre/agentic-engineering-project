# Agent Log — Recipe Manager & Weekly Menu Planner

Chronological record of agent prompts, tuning decisions, and system rules used during development.
Each entry must follow the format below so the CI pipeline can validate completeness.

---

## Log Entry Format

```
### [YYYY-MM-DD] <Short Title>
**Prompt / Trigger:** <Exact prompt or event that triggered this agent action>
**Decision / Rule Applied:** <What the agent decided and why>
**Outcome:** <Result — code generated, test passed, constraint leak found, etc.>
**Tuning Adjustment (if any):** <What was changed in the algorithm or constraint rules>
```

---

## Entries

### [2026-05-25] Workspace Initialization
**Prompt / Trigger:** User provided AGENTS.md + PRD.md and requested environment setup orchestration.
**Decision / Rule Applied:** Created dual-repo workspace structure, scaffolded `constraint-menu-generator` skill descriptor, initialized .NET 8 backend solution with layered architecture, initialized React/Vite/TypeScript frontend with feature-based structure.
**Outcome:** All directories and base files created. No code written yet — scaffolding only.
**Tuning Adjustment (if any):** N/A — initial setup.

### [2026-05-25] MenuGeneratorService — MinPoolSize set to 10
**Prompt / Trigger:** Unit test `GivenPoolSmallerThan10_WhenGenerating_ThenThrowsInsufficientRecipePoolException` with a pool of 8 recipes: algorithm deadlocked on day 4 because the 9-slot repetition window left zero candidates.
**Decision / Rule Applied:** The 3-day window spans 9 slots (3 days × 3 slots). To guarantee at least 1 candidate always exists, the pool must contain more recipes than the window: `MinPoolSize = windowSize + 1 = 10`. Guard throws `InsufficientRecipePoolException` before the loop starts.
**Outcome:** Pool size guard passes; unit tests updated to use 12 eligible recipes for valid-pool tests. All 14 unit tests green.
**Tuning Adjustment (if any):** MinPoolSize raised from 3 → 10.

### [2026-05-25] Integration Test — Multi-statement SQL bug in Microsoft.Data.Sqlite
**Prompt / Trigger:** All integration tests returned HTTP 500 after `IntegrationTestFactory` was wired up. Server log showed `InvalidOperationException: Must add values for the following parameters: @recipeId, @orderIndex, @durationMinutes, @notes` inside `InsertStepsAsync`.
**Decision / Rule Applied:** `Microsoft.Data.Sqlite` does case-sensitive parameter matching. The anonymous object used `DurationMinutes` and `Notes` (PascalCase) but the SQL had `@durationMinutes` and `@notes` (camelCase). Additionally, multi-statement SQL (`INSERT; SELECT last_insert_rowid()`) in a single `ExecuteScalarAsync` call is unreliable — split into two separate calls.
**Outcome:** All parameter names aligned to camelCase in anonymous objects. INSERT and `SELECT last_insert_rowid()` separated into two calls. Applied to RecipeRepository (2 sites) and MenuRepository (1 site). All 9 integration tests green.
**Tuning Adjustment (if any):** N/A — bug fix, not algorithm tuning.

### [2026-05-25] Integration Test — In-memory SQLite keepalive connection
**Prompt / Trigger:** Integration tests returned HTTP 500 even after migration ran; GET /api/recipes/99999 returned 404 (schema intact) but POST /api/recipes returned 500 (no schema).
**Decision / Rule Applied:** Named in-memory SQLite databases (`file:{name}?mode=memory&cache=shared`) are destroyed when all connections close. DbUp opens connections to migrate, closes them, and the schema vanishes. A persistent `SqliteConnection` held open in `IntegrationTestFactory` for its entire lifetime prevents this. Additionally, `Program.cs` was changed to read the connection string from the DI-registered `SqliteConnectionFactory` (after `builder.Build()`) rather than from a local variable, so the test factory's replacement is honoured for migration.
**Outcome:** All 9 integration tests green. `IntegrationTestFactory` now owns a `_keepAlive` connection opened in the constructor and closed in `Dispose`.
**Tuning Adjustment (if any):** N/A — infrastructure fix.

### [2026-05-25] MenuRepository — Load full recipe steps for GroceryListService
**Prompt / Trigger:** Integration test `GetGroceryList_AfterMenuGeneration_ReturnsNonEmptyList` returned an empty grocery list. `GroceryListService.GetForMenuAsync` iterates `recipe.Steps` but `MenuRepository.GetByIdAsync` only loaded basic recipe header data.
**Decision / Rule Applied:** `MenuRepository.GetByIdAsync` is responsible for returning the complete `Menu` aggregate (including full recipe data). Added a second joined query that loads all steps and ingredients for every recipe in the menu in one pass. Two-pass construction: collect ingredient rows keyed by stepId, then build `RecipeStep` objects with fully populated `IReadOnlyList<RecipeStepIngredient>` (required by init-only setters).
**Outcome:** Grocery list correctly consolidates all 21 slot ingredients. All 9 integration tests green.
**Tuning Adjustment (if any):** N/A — architecture completion.

### [2026-05-25] Frontend — Complete feature implementation (F-01 through F-07)
**Prompt / Trigger:** Implementation plan approved by user; all frontend features built in sequence.
**Decision / Rule Applied:** Feature-based folder structure (`src/features/{recipes,menu,grocery}/`). TypeScript strict mode with no `any`. API client uses `VITE_API_URL` env var with `http://localhost:5000` fallback. Recipe form uses controlled `StepDraft[]` array; `role="group"` added to step containers to enable accessible querying in tests. ConstraintForm validates `min > max` client-side before calling the API.
**Outcome:** 7 frontend features implemented (types, API client, recipe list/detail, recipe form, constraint form, menu calendar, grocery list, routing). 35 Vitest tests, all green. TypeScript strict check clean.
**Tuning Adjustment (if any):** N/A — UI layer, no algorithm changes.
