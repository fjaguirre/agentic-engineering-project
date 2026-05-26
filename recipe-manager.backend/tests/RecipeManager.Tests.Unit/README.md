# RecipeManager.Tests.Unit

Unit tests for the Service layer. All tests run in-process with no database, network, or file-system access.

## Framework

- **xUnit** — test runner
- **FluentAssertions 8.10.0** — assertion DSL
- **Fakes** — hand-rolled in-memory doubles (no Moq)

## Test classes

| Class | Subject | Count |
|---|---|---|
| `MenuGeneratorServiceTests` | Determinism, exclusion, repetition, pool size, calorie window, output shape | 10 |
| `GroceryListServiceTests` | Ingredient consolidation, unit sensitivity, scale factor, sort order | 4 |

## Helpers

| File | Purpose |
|---|---|
| `Helpers/RecipeBuilder.cs` | Creates single `Recipe` or a numbered pool of N recipes |
| `Fakes/FakeRecipeRepository.cs` | In-memory `IRecipeRepository` backed by a provided list |
| `Fakes/FakeMenuRepository.cs` | Minimal `IMenuRepository` that auto-increments ID; no persistence |
| `Fakes/FakeMenuRepositoryWithData.cs` | Returns a pre-built `Menu` object; used by grocery tests |

## Running

```bash
dotnet test tests/RecipeManager.Tests.Unit
```

All 14 tests complete in under 500 ms.
