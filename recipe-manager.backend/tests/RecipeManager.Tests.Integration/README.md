# RecipeManager.Tests.Integration

HTTP-level integration tests. Each test class boots a real ASP.NET Core host backed by an isolated, named in-memory SQLite database. No mocking.

## Framework

- **xUnit** — test runner with `IClassFixture<IntegrationTestFactory>` for shared host per class
- **Microsoft.AspNetCore.Mvc.Testing 8** — `WebApplicationFactory<Program>` host
- **FluentAssertions 8.10.0** — assertion DSL
- **Microsoft.Data.Sqlite** — in-memory SQLite (URI mode with shared cache)

## Isolation strategy

`IntegrationTestFactory` creates a unique named in-memory SQLite database (`file:{guid}?mode=memory&cache=shared`) for every test class instance. A persistent `SqliteConnection` is held open for the factory lifetime to prevent the in-memory database from being destroyed between connections. DbUp migration runs once when the host starts, against the test database.

Key override: `ConfigureWebHost` removes the real `SqliteConnectionFactory` singleton and registers a replacement pointing to the in-memory URI. `Program.cs` reads the connection string from DI after `builder.Build()`, so the test factory's replacement is honoured.

## Test classes

| Class | Coverage |
|---|---|
| `RecipeCrudTests` | POST (201), GET (200 / 404), DELETE (204 then 404) |
| `MenuPipelineTests` | Generate (201 + 21 slots), determinism across two generates with same seed, grocery list non-empty, GET menu by ID after persistence |

## Running

```bash
dotnet test tests/RecipeManager.Tests.Integration
```

9 tests, completes in approximately 1–2 seconds.
