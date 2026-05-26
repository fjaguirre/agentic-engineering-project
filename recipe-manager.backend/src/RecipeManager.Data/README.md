# RecipeManager.Data

Holds the domain entities, API contract DTOs, and the DbUp migration bootstrapper. This project has **no dependency on any other project in this solution** — it is the bottom of the dependency chain.

---

## Entity Model

```
Recipe (1) ──< RecipeTag >── (many) Tag
Recipe (1) ──< RecipeStep
                  RecipeStep (1) ──< RecipeStepAction >── (many) CulinaryAction
                  RecipeStep (1) ──< RecipeStepIngredient >── Ingredient

Menu (1) ──< MenuSlot >── Recipe
```

### Key Design Decisions

- **`Recipe.Tags`** and **`Recipe.Steps`** are `IReadOnlyList<T>` — repositories populate them; callers cannot mutate them.
- **`RecipeStepIngredient.IngredientName`** is a denormalized column read alongside the join so repositories can return a fully populated object without a second round-trip.
- **`MealSlot`** enum is co-located with `MenuSlot` to avoid a separate file for a three-value enum.

---

## DTO Contract

| DTO / Request | Direction | Purpose |
|---|---|---|
| `CreateRecipeRequest` | API → Service | Full recipe creation payload |
| `UpdateRecipeRequest` | API → Service | Full recipe replacement (same shape as create) |
| `CreateStepRequest` | nested | One step with its actions and ingredients |
| `CreateStepIngredientRequest` | nested | One ingredient binding within a step |
| `RecipeDto` | Service → API | Full recipe response graph |
| `RecipeStepDto` | nested | One step with resolved action names and ingredients |
| `RecipeStepIngredientDto` | nested | Ingredient with quantity and unit |
| `TagDto` | Service → API | Tag id + name pair |
| `MenuConstraintsRequest` | API → Service | Seed, calorie window, excluded tags, target servings |
| `MenuDto` | Service → API | Generated menu with all 21 populated slots |
| `MenuSlotDto` | nested | Day number, meal slot string, and full recipe |
| `GroceryLineItemDto` | Service → API | Consolidated ingredient line with scaled quantity |

---

## DbUp Migration Workflow

### How it works

1. `DatabaseBootstrapper.MigrateUp(connectionString)` is called once at application startup (inside `Program.cs`).
2. DbUp creates the `SchemaVersions` table on the first run to track which scripts have been applied.
3. All `.sql` files in the `Migrations/` folder are compiled as **embedded resources** (see `.csproj`) and discovered automatically.
4. Scripts are applied in **ascending alphabetical order** (prefix-driven: `001_`, `002_`, …). Each script runs inside its own transaction (`WithTransactionPerScript`).
5. On subsequent starts, only unapplied scripts are executed — already-applied scripts are skipped.

### Naming Convention

```
NNN_DescriptiveName.sql
```
Where `NNN` is a zero-padded three-digit integer (e.g., `001`, `002`, `015`).

### Rules

- **Never modify** an already-applied migration file. The `SchemaVersions` checksum will mismatch and DbUp will refuse to run.
- Always add a new numbered script instead.
- All SQL must be **ANSI-compliant** — no SQLite-exclusive syntax (e.g., avoid `PRAGMA` in migrations; use standard `CREATE TABLE IF NOT EXISTS`).
- The initial `Actions` seed data is included in `001_InitialSchema.sql` using `INSERT OR IGNORE` to make it idempotent if ever re-run manually.

### Adding a New Migration

```bash
# Create the file (increment the prefix by 1)
touch src/RecipeManager.Data/Migrations/002_AddCalorieIndex.sql
# Write ANSI-compliant SQL, then rebuild — the .csproj EmbeddedResource glob picks it up automatically
```
