# RecipeManager.API

ASP.NET Core 8 Web API — the entry point for all HTTP traffic. Receives requests, delegates to the Service layer, and returns DTOs as JSON.

---

## Endpoint Reference

### Recipes

| Method | Route | Request Body | Success | Description |
|---|---|---|---|---|
| GET | `/api/recipes` | — | 200 `RecipeDto[]` | List all recipes (tags only, no steps) |
| GET | `/api/recipes/{id}` | — | 200 `RecipeDto` | Get one recipe with full step tree |
| POST | `/api/recipes` | `CreateRecipeRequest` | 201 + Location header | Create a new recipe |
| PUT | `/api/recipes/{id}` | `UpdateRecipeRequest` | 204 | Replace a recipe (full update) |
| DELETE | `/api/recipes/{id}` | — | 204 | Delete a recipe and all its steps |

### Tags

| Method | Route | Request Body | Success | Description |
|---|---|---|---|---|
| GET | `/api/tags` | — | 200 `TagDto[]` | List all tags for use in filters |

### Menu

| Method | Route | Request Body | Success | Description |
|---|---|---|---|---|
| POST | `/api/menus/generate` | `MenuConstraintsRequest` | 201 `MenuDto` | Generate and persist a 7-day menu |
| GET | `/api/menus/{id}` | — | 200 `MenuDto` | Retrieve a previously generated menu |
| GET | `/api/menus` | — | 200 `MenuDto[]` | List all generated menus (header only) |

### Grocery

| Method | Route | Request Body | Success | Description |
|---|---|---|---|---|
| GET | `/api/menus/{menuId}/grocery` | — | 200 `GroceryLineItemDto[]` | Consolidated grocery list for a menu |

---

## Error Response Contract

All errors return JSON with the shape:

```json
{ "status": 422, "detail": "Human-readable message" }
```

| HTTP Status | Domain cause |
|---|---|
| 400 Bad Request | Validation failure (empty title, negative calories, etc.) |
| 404 Not Found | Recipe or Menu id does not exist |
| 422 Unprocessable | Constraint impossible, calorie window unreachable, insufficient pool |
| 500 Internal Server Error | Unexpected error (details not leaked) |

---

## DI Registration

```
SqliteConnectionFactory   → Singleton
IRecipeRepository         → Scoped  (RecipeRepository)
IIngredientRepository     → Scoped  (IngredientRepository)
ITagRepository            → Scoped  (TagRepository)
IMenuRepository           → Scoped  (MenuRepository)
IRecipeService            → Scoped  (RecipeService)
IMenuGeneratorService     → Scoped  (MenuGeneratorService)
IGroceryListService       → Scoped  (GroceryListService)
```

## CORS

The default policy allows `http://localhost:5173` (Vite dev server). Override via `appsettings.json`:

```json
{ "Cors": { "AllowedOrigin": "https://your-frontend.com" } }
```

## Database

DbUp runs all pending migrations at startup. The SQLite file path is configurable:

```json
{ "Database": { "Path": "recipe-manager.db" } }
```

For integration tests, the path is overridden to an in-memory SQLite URI.
