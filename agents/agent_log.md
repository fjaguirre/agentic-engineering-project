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

---

### [2026-05-26] Frontend — Vite template styles removed
**Prompt / Trigger:** User reported a dark background in the app UI ("Clean the front end of those default styles from template, so I can see a clean white background"), confirmed by screenshot.
**Decision / Rule Applied:** The Vite scaffold generates `src/index.css` with a `@media (prefers-color-scheme: dark)` block that sets `background: #16171d`. Rather than patching individual rules, replaced the entire 285-line template file with a minimal ~20-line reset: `box-sizing: border-box`, light `body` with `color: #111; background: #fff`, and a centered `#root` max-width container. `src/App.css` was cleared to an empty comment (all template classes were unused).
**Outcome:** App renders on a clean white background. No regressions in the 35 existing tests.
**Tuning Adjustment (if any):** N/A — styling only.

### [2026-05-26] Backend — Fix empty JSON body on recipe create
**Prompt / Trigger:** User reported "Failed to execute 'json' on 'Response': Unexpected end of JSON input" when submitting the Create Recipe form. The error appeared in the UI notification; no logs were produced because Serilog had not yet been added.
**Decision / Rule Applied:** Root cause: `RecipesController.CreateAsync` returned `CreatedAtAction(nameof(GetById), new { id }, null)` — passing `null` as the value argument produces an HTTP 201 with an empty body. The frontend's `request<Recipe>()` helper always called `.json()` on the response, which throws on an empty body. Two-part fix: (1) backend returns `new { id }` as the body so the client gets the new recipe's ID; (2) frontend `recipesApi.create` return type changed from `Recipe` to `{ id: number }` so callers navigate using the returned ID rather than relying on a full recipe object.
**Outcome:** Recipe create succeeds; the form navigates to `/recipes/{id}` using the returned ID. Error eliminated.
**Tuning Adjustment (if any):** N/A — bug fix.

### [2026-05-26] Backend — Serilog rolling-file logging added
**Prompt / Trigger:** User noted "I don't see logs in console, what is fine if we have logs in a file, please add it if not done yet."
**Decision / Rule Applied:** Added `Serilog.AspNetCore` 10.0.0 and `Serilog.Sinks.File` 7.0.0 to `RecipeManager.API.csproj`. Configured `Log.Logger` before `WebApplication.CreateBuilder` using a `LoggerConfiguration` that writes to Console and to a rolling daily file at `logs/app-.log` (7-file retention). `builder.Host.UseSerilog()` replaces the default Microsoft logging pipeline. `Microsoft.AspNetCore` namespace overridden to `Warning` to suppress high-volume request logs.
**Outcome:** Application writes structured logs to `logs/app-YYYYMMDD.log`. Existing tests unaffected (integration factory uses in-memory DB; logging is not intercepted in tests).
**Tuning Adjustment (if any):** N/A — observability addition.

### [2026-05-26] Frontend — Step preview relocated to dedicated section
**Prompt / Trigger:** User screenshot showed the step preview sentence appearing inside each StepCard accordion. User requested: "I want the preview out of the 'Steps' section, in a section below 'Preview' with the numbered list of steps."
**Decision / Rule Applied:** Removed the per-step `generatePreview` call from `StepCard`. Added a new `<fieldset>` block below the Steps section in `RecipeForm`, rendering an `<ol>` where each `<li>` calls `generatePreview(step)` for all steps in order. This consolidates all step summaries into a single scannable list the user can reference while editing, matching the mental model of a recipe card preview.
**Outcome:** Preview section appears as a numbered list below the step editors. All 37 frontend tests green.
**Tuning Adjustment (if any):** N/A — UX reorganization.

### [2026-05-26] RecipeDetail — Steps rendered as natural-language sentences
**Prompt / Trigger:** User screenshot showed recipe detail (`/recipes/:id`) rendering steps as raw fields (action list, ingredient bullet points). User: "In view recipe, I want the steps like in the preview."
**Decision / Rule Applied:** Added `stepToSentence(step: RecipeStep): string` to `RecipeDetail.tsx`, mirroring the `generatePreview` logic from `RecipeForm` but operating on the API `RecipeStep` type. Sentence pattern: `[actions joined by " and "] [qty unit of ingredient, ...] during [duration]. [notes]`. Free-text steps (no actions, no meaningful ingredients, null duration) return only the notes string. The step `<ol>` now renders `stepToSentence(step)` per item instead of sub-lists.
**Outcome:** Recipe detail displays steps identically to the form preview. `RecipeDetail.test.tsx` test updated: assertion changed from `/200 g Salmon/i` to `/Grill 200 g of Salmon during 15 minutes/i` to match the full sentence. All 37 tests green.
**Tuning Adjustment (if any):** N/A — display fix.

### [2026-05-26] Backend + Frontend — Fix free-text step detection (sentinel ingredient)
**Prompt / Trigger:** User reported: "The step entered using the 'free text step' option is loaded as a note in the edit mode and not loaded correctly in the preview." Free-text steps in edit mode showed the step's notes text inside an ingredient row rather than in the free-text textarea.
**Decision / Rule Applied:** Root cause was a two-point sentinel leakage. `RecipeService.FlattenSteps` adds a sentinel row `("", 0, "")` for ingredient-less steps so the grouping logic in `InsertStepsAsync` has at least one row per step. However, `InsertStepsAsync` was inserting the empty-name sentinel as a real ingredient, which came back from the API as `ingredients: [{ ingredientName: "" }]`. This made `ingredients.length === 0` false, so the free-text detection check failed on both the form load and the preview generator. Fixed in two places: (1) `InsertStepsAsync` in `RecipeRepository.cs` skips rows where `item.Name` is empty (`if (string.IsNullOrEmpty(item.Name)) continue`); (2) both `generatePreview` in `RecipeForm.tsx` and `stepToSentence` in `RecipeDetail.tsx` filter to `meaningfulIngredients` (non-blank `ingredientName`) before evaluating the free-text condition, making the frontend resilient to any lingering stale records.
**Outcome:** Free-text steps load into the free-text textarea on edit, display correctly in the preview, and are stored without a spurious empty ingredient row. All 23 backend tests and 37 frontend tests green.
**Tuning Adjustment (if any):** N/A — bug fix.

### [2026-05-26] RecipeForm — Test suite updated after component rewrite
**Prompt / Trigger:** After `RecipeForm.tsx` was rewritten to add an action dropdown (culinary action chips), free-text mode, and optional-field checkboxes, the existing `RecipeForm.test.tsx` targeted removed selectors and was missing the `actionsApi` mock.
**Decision / Rule Applied:** Added `actionsApi: { getAll: vi.fn() }` to the `vi.mock('../../api')` factory. Added `mockActionsApi` typed reference and a `sampleActions: CulinaryAction[]` fixture. Updated "starts with one step" to assert the action `combobox` exists and that the quantity spinbutton is absent by default (ingredients hidden until checkbox is checked). Removed text-input interaction from "reorders steps" — reordering is now positional, not text-driven. Added two new tests: "shows free text textarea when free text option is selected" (selects the Free Text sentinel from the dropdown, asserts `<textarea>` appears) and "shows ingredient rows when Ingredients checkbox is checked" (clicks the checkbox, asserts quantity spinbutton appears).
**Outcome:** 37 tests green. New tests cover the two key UX modes added to the form.
**Tuning Adjustment (if any):** N/A — test maintenance.

### [2026-05-26] Backend — Seed 20 diverse recipes (migration 002)
**Prompt / Trigger:** User: "Generate seed data for 20 recipes of different types, try to use close to real nutritional data."
**Decision / Rule Applied:** Added `src/RecipeManager.Data/Migrations/002_SeedRecipes.sql` as a DbUp `EmbeddedResource` (picked up automatically by the existing `Migrations\*.sql` glob in the .csproj). Script inserts 7 dietary tags, 74 ingredients, 20 recipes spanning protein types (chicken, beef, pork, fish, shrimp, turkey, eggs, legumes), meal categories (breakfast, lunch, dinner), and dietary profiles (GlutenFree, HighProtein, Vegetarian, Vegan, LowCarb, DairyFree). All recipe-to-tag and recipe-to-step joins use `(SELECT MIN(Id) FROM Recipes WHERE Title = 'X')` subqueries rather than hardcoded IDs, making the migration safe even if the user created recipes with the same titles before migration ran. `INSERT OR IGNORE` used on all UNIQUE-constrained tables (Tags, Ingredients, RecipeTags).
**Outcome:** Migration applied via DbUp on next startup. All 20 recipes confirmed present via `GET /api/recipes` (returning 20 records). All 23 backend tests still green (integration tests use isolated in-memory DB, unaffected by seed data).
**Tuning Adjustment (if any):** N/A — data seeding, no algorithm changes.

### [2026-05-26] Repository — Initialize monorepo at workspace root
**Prompt / Trigger:** User: "As I need to upload this workspace to GitHub, make the root a git repository (called agentic-engineering-project), so we can push all the Claude, AGENTS.md and PRD.md and generated app projects."
**Decision / Rule Applied:** Both sub-projects had independent `.git` folders from prior development. Removed nested `.git` directories from `recipe-manager.backend/` and `recipe-manager.frontend/` to flatten them into the root repo (avoiding git submodule complexity). Ran `git init -b main` at the workspace root. Wrote a root `.gitignore` covering both stacks: `**/bin/`, `**/obj/`, `*.db`, `**/logs/`, `**/node_modules/`, `**/dist/`. Added `.gitattributes` with `* text=auto eol=lf` to normalize line endings cross-platform. Initial commit included all 137 files: AGENTS.md, PRD.md, agents/, skills/, .claude/, and both project trees.
**Outcome:** Single monorepo committed on `main`. Ready to push to `github.com/fragui/agentic-engineering-project`.
**Tuning Adjustment (if any):** N/A — repository infrastructure.

### [2026-05-26] CI — GitHub Actions pipelines for backend and frontend
**Prompt / Trigger:** PRD section 4.2 requirement: "CI Pipelines: The code, agent logs, and test matrix validation must pass cleanly on the CI runner." User explicitly requested pipelines with status badge generation.
**Decision / Rule Applied:** Created two workflow files in `.github/workflows/`, both triggering on `push` and `pull_request` to `main`. Backend pipeline (`.github/workflows/backend-ci.yml`): uses `actions/setup-dotnet@v4` with `dotnet-version: 8.0.x`, runs `dotnet restore RecipeManager.sln` → `dotnet build --configuration Release` → `dotnet test --no-build --configuration Release` with TRX logger, uploads test result artifacts. No external service needed — integration tests use `IntegrationTestFactory` with an in-memory named SQLite URI (`file:{guid}?mode=memory&cache=shared`). Frontend pipeline (`.github/workflows/frontend-ci.yml`): uses `actions/setup-node@v4` with `node-version: 22`, caches npm using `package-lock.json` as the cache key, runs `npm ci` → `npm test` (`vitest run`). Node 22 chosen as the current LTS matching the TypeScript 6.x and Vitest 4.x dependency versions.
**Outcome:** Workflows committed. Once the repo is pushed to GitHub, badge URLs will be available at `https://github.com/fragui/agentic-engineering-project/actions/workflows/backend-ci.yml/badge.svg` and `frontend-ci.yml/badge.svg`. Local test runs confirm 23 backend + 37 frontend tests pass, making first CI run expected to be green.
**Tuning Adjustment (if any):** N/A — CI infrastructure.
