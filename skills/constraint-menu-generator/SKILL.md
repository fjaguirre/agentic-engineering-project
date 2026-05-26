# Skill: constraint-menu-generator

**Version:** 1.0.0
**Domain:** Recipe Manager — Weekly Menu Planning Engine
**Layer:** `RecipeManager.Service` (C# .NET 8)

---

## 1. Purpose

This skill teaches the agent how to design, implement, and verify the deterministic constraint-based menu generation algorithm that produces a reproducible 7-day meal plan (21 slots: Breakfast / Lunch / Dinner × 7 days) from a pool of recipes and user-defined constraints.

---

## 2. Context Registration

Before generating any code, the agent must ingest and validate the following context:

### 2.1 Recipe Pool Schema (inputs)
```
Recipe {
  Id: int
  Title: string
  Tags: string[]              // e.g. ["GlutenFree", "Vegan", "Dairy"]
  Calories: int               // per serving
  Macros: { Protein, Carbs, Fat }  // grams per serving
  Servings: int
  PrimaryProtein: string      // e.g. "Chicken", "Tofu", "Beef"
  Ingredients: Ingredient[]
}
```

### 2.2 User Constraints Schema (inputs)
```
MenuConstraints {
  ExcludedTags: string[]       // allergens / dietary restrictions
  DailyCalorieMin: int
  DailyCalorieMax: int
  Seed: int                    // integer seed for deterministic selection
  TargetServings: int          // servings per menu slot (scale factor)
}
```

### 2.3 Seed Contract
- The `Seed` integer is the single source of randomness.
- All pseudo-random selections MUST use `new System.Random(seed)` — never `Random.Shared`, `Guid.NewGuid()`, or `DateTime.Now`.
- The seed instance must be created once and passed through the entire assembly loop.

---

## 3. Deterministic Code Generation Rules

### 3.1 Selection Loop Structure
```
For day in [1..7]:
  For slot in [Breakfast, Lunch, Dinner]:
    candidates = FilterByExclusion(recipePool, constraints.ExcludedTags)
    candidates = FilterByRepetition(candidates, placedRecipes, day, slot)
    candidates = FilterByProteinVariety(candidates, placedRecipes, day)
    selected   = candidates[rng.Next(0, candidates.Count)]
    Place(selected, day, slot)
    Accumulate daily calories
  Assert daily calories in [DailyCalorieMin, DailyCalorieMax]
```

### 3.2 Constraint Enforcement Protocols

| Constraint | Rule | Failure Mode |
|---|---|---|
| **Exclusion** | If any Recipe.Tags intersects ExcludedTags → remove from pool permanently | Throw `ConstraintImpossibleException` if pool empties |
| **Calorie Window** | Daily sum must satisfy `Min ≤ sum ≤ Max` | Retry slot selection up to `MaxRetries` (default 50), then throw `CalorieTargetUnreachableException` |
| **Recipe Repetition** | Same recipe cannot appear within a 3-day rolling window | Skip candidate; mark ineligible for current slot |
| **Protein Variety** | Same `PrimaryProtein` cannot appear in consecutive day positions | Skip candidate if previous day same slot shares protein |

### 3.3 Forbidden Patterns
- No `Guid.NewGuid()` inside the assembly loop.
- No `DateTime.Now` or `DateTime.UtcNow` dependencies.
- No `Task.Run` or async inside the core selection loop — it must be synchronous and deterministic.
- No static mutable state; all state passed explicitly.

---

## 4. Grocery List Consolidation Rules

After the 7-day menu is assembled, the agent must implement `GroceryListService` following these rules:

1. **Unit-Matching Sum:** `200g Rice` + `300g Rice` → `500g Rice`
2. **Incompatible-Unit Separation:** `2 cloves Garlic` + `10g Garlic` → two separate line items under `Garlic` header
3. **Scale Factor:** `ingredient.Quantity × (targetServings / recipe.Servings)`
4. Output: `List<GroceryLineItem>` sorted alphabetically by ingredient name

---

## 5. Custom Exceptions (Service Layer)

The agent must implement these domain exceptions in `RecipeManager.Service/Exceptions/`:

```csharp
ConstraintImpossibleException(string message)   // Pool exhausted by exclusions
CalorieTargetUnreachableException(string message, int day, MealSlot slot)
InsufficientRecipePoolException(string message, int requiredMinimum, int actual)
```

All exceptions must carry descriptive business-level messages (no raw stack dumps to API consumers).

---

## 6. Automated Test Scaffold Directive

When the agent implements the menu generator service, it must simultaneously generate:

### 6.1 Unit Tests (`RecipeManager.Tests.Unit/MenuGeneratorTests.cs`)
- `GivenSameSeedAndPool_WhenGeneratingTwice_ThenMenusAreIdentical`
- `GivenExcludedGlutenTag_WhenGenerating_ThenNoGlutenRecipeAppearsInMenu`
- `GivenEmptyPool_WhenGenerating_ThenThrowsConstraintImpossibleException`
- `GivenRepetitionRule_WhenGenerating_ThenNoRecipeRepeatsWithin3Days`
- `GivenCalorieWindow_WhenGenerating_ThenEachDayIsWithinBounds`

### 6.2 Integration Tests (`RecipeManager.Tests.Integration/MenuPipelineTests.cs`)
- `FullPipeline_CreateRecipes_GenerateMenu_ExportGroceryList_ReturnsValid200`
- `FullPipeline_WithExclusionConstraint_NeverLeaksConstraintViolation`

### 6.3 Assertion Standards
- Use `FluentAssertions` for all assertions.
- Each test must have an explicit `// Arrange / Act / Assert` comment block.
- Constraint-compliance tests must iterate over ALL 21 slots to verify zero leaks.

---

## 7. Agent Accountability

After each implementation step the agent must append an entry to `agents/agent_log.md` recording:
- The exact prompt trigger
- The algorithmic decision made
- The test outcome
- Any tuning adjustment applied to loop boundaries or retry limits
