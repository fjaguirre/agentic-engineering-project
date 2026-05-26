# RecipeManager.Service

Contains all business logic. This layer receives DTOs from the API, calls repository interfaces, applies domain rules, and returns DTOs. It has no knowledge of HTTP, database drivers, or connection strings.

---

## Services

| Service | Interface | Responsibility |
|---|---|---|
| `RecipeService` | `IRecipeService` | CRUD orchestration, validation, DTO mapping |
| `MenuGeneratorService` | `IMenuGeneratorService` | Deterministic 7-day menu generation |
| `GroceryListService` | `IGroceryListService` | Ingredient aggregation with unit consolidation |

---

## MenuGeneratorService — Algorithm Flow

### Invariants (enforced by code; never negotiable)

1. `new Random(seed)` is created **once** and passed through the entire loop — no `Random.Shared`, no `Guid.NewGuid()`, no `DateTime.Now`.
2. For identical `(pool, constraints, seed)` the output is **100% identical** across runs and machines.
3. The algorithm is **synchronous inside the loop** (no `await` between slot selections); the loop is pure deterministic computation.

### Step-by-step Flow

```
GenerateAsync(constraints)
│
├── 1. Load full recipe pool from IRecipeRepository
│
├── 2. EXCLUSION FILTER (permanent, applied once)
│       pool = pool.Where(r => r.Tags ∩ ExcludedTags == ∅)
│       if pool.Count == 0  → ConstraintImpossibleException
│       if pool.Count < 3   → InsufficientRecipePoolException
│
├── 3. SEED — rng = new Random(constraints.Seed)
│
└── 4. ASSEMBLY LOOP  for day in [1..7]:
          dailyCalories = 0
          for slot in [Breakfast, Lunch, Dinner]:
          │
          ├── candidates = pool
          │     .Where(PassesRepetitionGuard)     ← no repeat within 3-day window
          │     .Where(PassesProteinVariety)       ← no same protein on consecutive days
          │
          ├── if candidates empty → ConstraintImpossibleException
          │
          ├── selected = candidates[rng.Next(0, candidates.Count)]
          │
          ├── For the LAST slot of the day:
          │     assert (dailyCalories + slotCalories) ∈ [DailyCalorieMin, DailyCalorieMax]
          │     retry up to MaxRetries=50 if not satisfied
          │     if still fails → CalorieTargetUnreachableException
          │
          └── place selected, update trackers
```

### Constraint Table

| Constraint | Guard | Failure exception |
|---|---|---|
| Exclusion (allergens/dietary) | Permanent pre-filter | `ConstraintImpossibleException` |
| Recipe repetition (≤3 days) | `PassesRepetitionGuard` — sliding window of last `3×3=9` placements | `ConstraintImpossibleException` |
| Protein variety | `PassesProteinVariety` — compare `PrimaryProtein` to previous day | (candidate skipped; pool exhaustion → `ConstraintImpossibleException`) |
| Calorie window | Final-slot assertion with retry loop | `CalorieTargetUnreachableException` |

### Edge Cases and How They Break the App

| Scenario | Behavior |
|---|---|
| All recipes excluded by tags | `ConstraintImpossibleException` before the loop starts |
| Pool has < 3 recipes | `InsufficientRecipePoolException` — 3 distinct recipes needed for the 3-day window |
| Calorie window too narrow | After `MaxRetries=50`, throws `CalorieTargetUnreachableException` with day/slot context |
| All candidates filtered by protein variety | Falls through to `ConstraintImpossibleException`; solution: add recipes with `null` PrimaryProtein |
| Zero-calorie recipes in pool | Will be picked for any calorie window — considered intentional (the recipe has 0 kcal declared) |

---

## GroceryListService — Consolidation Rules

```
For each slot in the 7-day menu:
  For each step in the recipe:
    For each ingredient in the step:
      scaledQty = ingredient.Quantity × (targetServings / recipe.Servings)
      key = (IngredientName, Unit)          ← unit-sensitive grouping
      if key exists → sum quantities
      else → new line item
```

**Incompatible units:** Two entries for the same ingredient with different units (e.g., `2 cloves Garlic` vs `10g Garlic`) are emitted as **separate line items** sorted under the same ingredient name. They are never summed to prevent corrupting grocery metrics.

---

## Domain Exceptions

| Exception | When thrown |
|---|---|
| `ConstraintImpossibleException` | Recipe pool is empty after exclusions, or all candidates are filtered |
| `CalorieTargetUnreachableException` | Cannot satisfy calorie window after MaxRetries on a given day/slot |
| `InsufficientRecipePoolException` | Pool size < 3 after exclusions |
| `RecipeNotFoundException` | GetById/Update/Delete for a non-existent recipe id |
