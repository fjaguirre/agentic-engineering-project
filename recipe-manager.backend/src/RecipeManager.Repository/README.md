# RecipeManager.Repository

Implements all data access using **Dapper** against a SQLite (dev) or SQL Server (prod) database. This layer owns the SQL — no LINQ-to-SQL, no EF Core, no query builders. Every query is a raw, parameterized SQL string.

---

## Design Principles

- **Interfaces first:** Every repository has a matching interface in `Interfaces/`. The Service layer depends on interfaces, never on concrete classes. This allows integration tests to substitute an in-memory SQLite database without touching the Service code.
- **Connection factory:** `SqliteConnectionFactory` centralizes connection-string resolution and `IDbConnection` creation. Repositories receive it via constructor injection.
- **No transactions in repositories:** Transactions that span multiple repositories are coordinated by the Service layer, which calls `IDbConnection.BeginTransaction()` and passes it down.
- **SQL portability:** All queries use ANSI SQL. SQLite-only functions (e.g. `datetime('now')`) only appear in migration scripts — query results are coerced into C# types without relying on database functions.

---

## Multi-Query Recipe Loading

A `Recipe` has two child collections (`Tags` and `Steps`) and each `Step` has two child collections (`Actions` and `Ingredients`). Loading this in a single round-trip uses Dapper's multi-mapping:

```
Query 1: SELECT recipe columns FROM Recipes WHERE Id = @id
Query 2: SELECT t.* FROM Tags t JOIN RecipeTags rt ON rt.TagId = t.Id WHERE rt.RecipeId = @id
Query 3: SELECT s.*, a.Name AS ActionName, rsi.*, i.Name AS IngredientName
          FROM RecipeSteps s
          LEFT JOIN RecipeStepActions rsa ON rsa.StepId = s.Id
          LEFT JOIN Actions a ON a.Id = rsa.ActionId
          LEFT JOIN RecipeStepIngredients rsi ON rsi.StepId = s.Id
          LEFT JOIN Ingredients i ON i.Id = rsi.IngredientId
          WHERE s.RecipeId = @id
          ORDER BY s.OrderIndex
```

The result of Query 3 produces one row per (step × action × ingredient) combination. The `RecipeRepository` implementation groups these rows by `StepId` to reconstruct the tree.

---

## Repositories

| Interface | Concrete | Responsibility |
|---|---|---|
| `IRecipeRepository` | `RecipeRepository` | Full recipe CRUD including steps, actions, ingredients, and tags |
| `ITagRepository` | `TagRepository` | Tag lookup / upsert (GetOrCreate pattern) |
| `IIngredientRepository` | `IngredientRepository` | Ingredient lookup / upsert (GetOrCreate pattern) |
| `IMenuRepository` | `MenuRepository` | Persist and retrieve generated menus with their slots |

---

## GetOrCreate Pattern

`ITagRepository.GetOrCreateAsync(name)` and `IIngredientRepository.GetOrCreateAsync(name)` implement a safe upsert:

```sql
INSERT INTO Tags (Name) VALUES (@name)
ON CONFLICT(Name) DO NOTHING;
SELECT Id FROM Tags WHERE Name = @name;
```

This is idempotent and avoids unique constraint violations under normal usage. It is not safe for high-concurrency batch inserts — for the MVP this is acceptable.
