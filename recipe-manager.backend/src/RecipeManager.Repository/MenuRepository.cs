using System.Data;
using Dapper;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Repository;

public sealed class MenuRepository(SqliteConnectionFactory connectionFactory) : IMenuRepository
{
    public async Task<Menu?> GetByIdAsync(int id)
    {
        using IDbConnection db = connectionFactory.Create();

        Menu? menu = await db.QuerySingleOrDefaultAsync<Menu>(
            "SELECT Id, Seed, GeneratedAt FROM Menus WHERE Id = @id", new { id });

        if (menu is null) return null;

        IEnumerable<dynamic> slotRows = await db.QueryAsync(
            """
            SELECT ms.Id, ms.Day, ms.MealSlot,
                   r.Id AS RecipeId, r.Title, r.Servings, r.CaloriesPerServing,
                   r.ProteinG, r.CarbsG, r.FatG, r.PrimaryProtein,
                   r.CreatedAt, r.UpdatedAt
            FROM MenuSlots ms
            JOIN Recipes r ON r.Id = ms.RecipeId
            WHERE ms.MenuId = @id
            ORDER BY ms.Day, ms.MealSlot
            """,
            new { id });

        // Load steps and ingredients for all recipes in this menu in one query
        IEnumerable<dynamic> stepRows = await db.QueryAsync(
            """
            SELECT rs.RecipeId, rs.Id AS StepId, rs.OrderIndex, rs.DurationMinutes, rs.Notes,
                   rsi.Id AS RsiId, rsi.Quantity, rsi.Unit, i.Name AS IngredientName
            FROM MenuSlots ms
            JOIN RecipeSteps rs ON rs.RecipeId = ms.RecipeId
            LEFT JOIN RecipeStepIngredients rsi ON rsi.StepId = rs.Id
            LEFT JOIN Ingredients i ON i.Id = rsi.IngredientId
            WHERE ms.MenuId = @id
            ORDER BY rs.RecipeId, rs.OrderIndex
            """,
            new { id });

        // Two-pass: collect ingredient rows per stepId, then build step objects with init-only setters
        var stepData = new Dictionary<int, (int RecipeId, int OrderIndex, int? DurationMinutes, string? Notes, List<RecipeStepIngredient> Ingredients)>();

        foreach (dynamic row in stepRows)
        {
            int stepId = (int)row.StepId;

            if (!stepData.ContainsKey(stepId))
            {
                stepData[stepId] = (
                    (int)row.RecipeId,
                    (int)row.OrderIndex,
                    row.DurationMinutes is null ? null : (int?)row.DurationMinutes,
                    (string?)row.Notes,
                    []);
            }

            if (row.RsiId is not null)
            {
                var (_, _, _, _, ingredients) = stepData[stepId];
                int rsiId = (int)row.RsiId;
                if (!ingredients.Any(i => i.Id == rsiId))
                {
                    ingredients.Add(new RecipeStepIngredient
                    {
                        Id = rsiId,
                        StepId = stepId,
                        Quantity = (double)row.Quantity,
                        Unit = (string)row.Unit,
                        IngredientName = (string)row.IngredientName,
                    });
                }
            }
        }

        // Group built steps by RecipeId
        var stepsByRecipe = stepData
            .GroupBy(kv => kv.Value.RecipeId)
            .ToDictionary(
                g => g.Key,
                g => (IReadOnlyList<RecipeStep>)g
                    .OrderBy(kv => kv.Value.OrderIndex)
                    .Select(kv => new RecipeStep
                    {
                        Id = kv.Key,
                        RecipeId = kv.Value.RecipeId,
                        OrderIndex = kv.Value.OrderIndex,
                        DurationMinutes = kv.Value.DurationMinutes,
                        Notes = kv.Value.Notes,
                        Actions = [],
                        Ingredients = kv.Value.Ingredients,
                    })
                    .ToList());

        List<MenuSlot> slots = slotRows.Select(row => new MenuSlot
        {
            Id = (int)row.Id,
            MenuId = id,
            Day = (int)row.Day,
            MealSlot = Enum.Parse<MealSlot>((string)row.MealSlot),
            RecipeId = (int)row.RecipeId,
            Recipe = new Recipe
            {
                Id = (int)row.RecipeId,
                Title = (string)row.Title,
                Servings = (int)row.Servings,
                CaloriesPerServing = (int)row.CaloriesPerServing,
                ProteinG = (double)row.ProteinG,
                CarbsG = (double)row.CarbsG,
                FatG = (double)row.FatG,
                PrimaryProtein = (string?)row.PrimaryProtein,
                CreatedAt = DateTime.Parse((string)row.CreatedAt),
                UpdatedAt = DateTime.Parse((string)row.UpdatedAt),
                Tags = [],
                Steps = stepsByRecipe.TryGetValue((int)row.RecipeId, out var steps) ? steps : [],
            },
        }).ToList();

        return new Menu
        {
            Id = menu.Id,
            Seed = menu.Seed,
            GeneratedAt = menu.GeneratedAt,
            Slots = slots,
        };
    }

    public async Task<IReadOnlyList<Menu>> GetAllAsync()
    {
        using IDbConnection db = connectionFactory.Create();
        IEnumerable<Menu> menus = await db.QueryAsync<Menu>(
            "SELECT Id, Seed, GeneratedAt FROM Menus ORDER BY GeneratedAt DESC");
        return menus.ToList();
    }

    public async Task<int> SaveAsync(Menu menu)
    {
        using IDbConnection db = connectionFactory.Create();
        db.Open();
        using IDbTransaction tx = db.BeginTransaction();

        await db.ExecuteAsync(
            "INSERT INTO Menus (Seed) VALUES (@Seed)",
            new { menu.Seed }, tx);
        int menuId = await db.ExecuteScalarAsync<int>("SELECT last_insert_rowid()", null, tx);

        foreach (MenuSlot slot in menu.Slots)
        {
            await db.ExecuteAsync(
                """
                INSERT INTO MenuSlots (MenuId, Day, MealSlot, RecipeId)
                VALUES (@menuId, @Day, @MealSlot, @RecipeId)
                """,
                new { menuId, slot.Day, MealSlot = slot.MealSlot.ToString(), slot.RecipeId },
                tx);
        }

        tx.Commit();
        return menuId;
    }
}
