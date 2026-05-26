using System.Data;
using Dapper;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Repository;

public sealed class RecipeRepository(SqliteConnectionFactory connectionFactory) : IRecipeRepository
{
    public async Task<IReadOnlyList<Recipe>> GetAllAsync()
    {
        using IDbConnection db = connectionFactory.Create();

        IEnumerable<dynamic> rows = await db.QueryAsync(
            """
            SELECT r.Id, r.Title, r.Servings, r.CaloriesPerServing,
                   r.ProteinG, r.CarbsG, r.FatG, r.PrimaryProtein,
                   r.CreatedAt, r.UpdatedAt,
                   t.Id AS TagId, t.Name AS TagName
            FROM Recipes r
            LEFT JOIN RecipeTags rt ON rt.RecipeId = r.Id
            LEFT JOIN Tags t ON t.Id = rt.TagId
            ORDER BY r.Id
            """);

        // List view: tags only, no step hydration
        var recipeMap = new Dictionary<int, (dynamic First, List<Tag> Tags)>();

        foreach (dynamic row in rows)
        {
            int id = (int)row.Id;
            if (!recipeMap.ContainsKey(id))
                recipeMap[id] = (row, new List<Tag>());

            if (row.TagId is not null)
            {
                int tagId = (int)row.TagId;
                var tags = recipeMap[id].Tags;
                if (!tags.Any(t => t.Id == tagId))
                    tags.Add(new Tag { Id = tagId, Name = (string)row.TagName });
            }
        }

        return recipeMap.Values.Select(entry => (Recipe)MapRecipe(entry.First, entry.Tags, new List<RecipeStep>())).ToList();
    }

    public async Task<Recipe?> GetByIdAsync(int id)
    {
        using IDbConnection db = connectionFactory.Create();

        IEnumerable<dynamic> headerRows = await db.QueryAsync(
            """
            SELECT r.Id, r.Title, r.Servings, r.CaloriesPerServing,
                   r.ProteinG, r.CarbsG, r.FatG, r.PrimaryProtein,
                   r.CreatedAt, r.UpdatedAt,
                   t.Id AS TagId, t.Name AS TagName
            FROM Recipes r
            LEFT JOIN RecipeTags rt ON rt.RecipeId = r.Id
            LEFT JOIN Tags t ON t.Id = rt.TagId
            WHERE r.Id = @id
            """,
            new { id });

        dynamic? header = headerRows.FirstOrDefault();
        if (header is null) return null;

        List<Tag> tags = [];
        foreach (dynamic row in headerRows)
        {
            if (row.TagId is null) continue;
            int tagId = (int)row.TagId;
            if (!tags.Any(t => t.Id == tagId))
                tags.Add(new Tag { Id = tagId, Name = (string)row.TagName });
        }

        IEnumerable<dynamic> stepRows = await db.QueryAsync(
            """
            SELECT s.Id AS StepId, s.OrderIndex, s.DurationMinutes, s.Notes,
                   a.Name AS ActionName,
                   rsi.Id AS RsiId, rsi.Quantity, rsi.Unit,
                   i.Id AS IngredientId, i.Name AS IngredientName
            FROM RecipeSteps s
            LEFT JOIN RecipeStepActions rsa ON rsa.StepId = s.Id
            LEFT JOIN Actions a ON a.Id = rsa.ActionId
            LEFT JOIN RecipeStepIngredients rsi ON rsi.StepId = s.Id
            LEFT JOIN Ingredients i ON i.Id = rsi.IngredientId
            WHERE s.RecipeId = @id
            ORDER BY s.OrderIndex
            """,
            new { id });

        List<RecipeStep> steps = BuildSteps(stepRows);

        return MapRecipe(header, tags, steps);
    }

    public async Task<int> CreateAsync(
        Recipe recipe,
        IReadOnlyList<string> tagNames,
        IReadOnlyList<(string Name, double Quantity, string Unit, int StepOrderIndex, IReadOnlyList<string> Actions, int? DurationMinutes, string? Notes)> stepIngredients)
    {
        using IDbConnection db = connectionFactory.Create();
        db.Open();
        using IDbTransaction tx = db.BeginTransaction();

        await db.ExecuteAsync(
            "INSERT INTO Recipes (Title, Servings, CaloriesPerServing, ProteinG, CarbsG, FatG, PrimaryProtein) VALUES (@Title, @Servings, @CaloriesPerServing, @ProteinG, @CarbsG, @FatG, @PrimaryProtein)",
            new
            {
                recipe.Title, recipe.Servings, recipe.CaloriesPerServing,
                recipe.ProteinG, recipe.CarbsG, recipe.FatG, recipe.PrimaryProtein
            },
            tx);
        int recipeId = await db.ExecuteScalarAsync<int>("SELECT last_insert_rowid()", null, tx);

        await AttachTagsAsync(db, tx, recipeId, tagNames);
        await InsertStepsAsync(db, tx, recipeId, stepIngredients);

        tx.Commit();
        return recipeId;
    }

    public async Task UpdateAsync(
        int id,
        Recipe recipe,
        IReadOnlyList<string> tagNames,
        IReadOnlyList<(string Name, double Quantity, string Unit, int StepOrderIndex, IReadOnlyList<string> Actions, int? DurationMinutes, string? Notes)> stepIngredients)
    {
        using IDbConnection db = connectionFactory.Create();
        db.Open();
        using IDbTransaction tx = db.BeginTransaction();

        await db.ExecuteAsync(
            """
            UPDATE Recipes
            SET Title = @Title, Servings = @Servings, CaloriesPerServing = @CaloriesPerServing,
                ProteinG = @ProteinG, CarbsG = @CarbsG, FatG = @FatG,
                PrimaryProtein = @PrimaryProtein, UpdatedAt = datetime('now')
            WHERE Id = @id
            """,
            new
            {
                id, recipe.Title, recipe.Servings, recipe.CaloriesPerServing,
                recipe.ProteinG, recipe.CarbsG, recipe.FatG, recipe.PrimaryProtein
            },
            tx);

        // Full replace: simpler than diffing for MVP scope
        await db.ExecuteAsync("DELETE FROM RecipeTags WHERE RecipeId = @id", new { id }, tx);
        await db.ExecuteAsync("DELETE FROM RecipeSteps WHERE RecipeId = @id", new { id }, tx);

        await AttachTagsAsync(db, tx, id, tagNames);
        await InsertStepsAsync(db, tx, id, stepIngredients);

        tx.Commit();
    }

    public async Task DeleteAsync(int id)
    {
        using IDbConnection db = connectionFactory.Create();
        await db.ExecuteAsync("DELETE FROM Recipes WHERE Id = @id", new { id });
    }

    private static Recipe MapRecipe(dynamic row, List<Tag> tags, List<RecipeStep> steps) =>
        new()
        {
            Id = (int)row.Id,
            Title = (string)row.Title,
            Servings = (int)row.Servings,
            CaloriesPerServing = (int)row.CaloriesPerServing,
            ProteinG = (double)row.ProteinG,
            CarbsG = (double)row.CarbsG,
            FatG = (double)row.FatG,
            PrimaryProtein = (string?)row.PrimaryProtein,
            CreatedAt = DateTime.Parse((string)row.CreatedAt),
            UpdatedAt = DateTime.Parse((string)row.UpdatedAt),
            Tags = tags,
            Steps = steps,
        };

    private static List<RecipeStep> BuildSteps(IEnumerable<dynamic> stepRows)
    {
        var stepMap = new Dictionary<int, (List<CulinaryAction> Actions, List<RecipeStepIngredient> Ingredients, dynamic FirstRow)>();

        foreach (dynamic row in stepRows)
        {
            int stepId = (int)row.StepId;

            if (!stepMap.ContainsKey(stepId))
                stepMap[stepId] = ([], [], row);

            var (actions, ingredients, _) = stepMap[stepId];

            if (row.ActionName is string actionName && !actions.Any(a => a.Name == actionName))
                actions.Add(new CulinaryAction { Name = actionName });

            if (row.RsiId is not null)
            {
                int rsiId = (int)row.RsiId;
                if (!ingredients.Any(i => i.Id == rsiId))
                    ingredients.Add(new RecipeStepIngredient
                    {
                        Id = rsiId,
                        StepId = stepId,
                        IngredientId = (int)row.IngredientId,
                        IngredientName = (string)row.IngredientName,
                        Quantity = (double)row.Quantity,
                        Unit = (string)row.Unit,
                    });
            }
        }

        return stepMap.Values
            .OrderBy(e => (int)e.FirstRow.OrderIndex)
            .Select(e => new RecipeStep
            {
                Id = (int)e.FirstRow.StepId,
                RecipeId = 0, // populated by query context; not stored redundantly here
                OrderIndex = (int)e.FirstRow.OrderIndex,
                DurationMinutes = e.FirstRow.DurationMinutes is null ? null : (int?)e.FirstRow.DurationMinutes,
                Notes = (string?)e.FirstRow.Notes,
                Actions = e.Actions,
                Ingredients = e.Ingredients,
            })
            .ToList();
    }

    private static async Task AttachTagsAsync(
        IDbConnection db, IDbTransaction tx, int recipeId, IReadOnlyList<string> tagNames)
    {
        foreach (string name in tagNames)
        {
            await db.ExecuteAsync(
                "INSERT INTO Tags (Name) VALUES (@name) ON CONFLICT(Name) DO NOTHING",
                new { name }, tx);

            int tagId = await db.ExecuteScalarAsync<int>(
                "SELECT Id FROM Tags WHERE Name = @name", new { name }, tx);

            await db.ExecuteAsync(
                "INSERT INTO RecipeTags (RecipeId, TagId) VALUES (@recipeId, @tagId) ON CONFLICT DO NOTHING",
                new { recipeId, tagId }, tx);
        }
    }

    private static async Task InsertStepsAsync(
        IDbConnection db,
        IDbTransaction tx,
        int recipeId,
        IReadOnlyList<(string Name, double Quantity, string Unit, int StepOrderIndex, IReadOnlyList<string> Actions, int? DurationMinutes, string? Notes)> stepIngredients)
    {
        var stepGroups = stepIngredients
            .GroupBy(s => s.StepOrderIndex)
            .OrderBy(g => g.Key);

        foreach (var group in stepGroups)
        {
            var first = group.First();

            await db.ExecuteAsync(
                "INSERT INTO RecipeSteps (RecipeId, OrderIndex, DurationMinutes, Notes) VALUES (@recipeId, @orderIndex, @durationMinutes, @notes)",
                new { recipeId, orderIndex = first.StepOrderIndex, durationMinutes = first.DurationMinutes, notes = first.Notes },
                tx);
            int stepId = await db.ExecuteScalarAsync<int>("SELECT last_insert_rowid()", null, tx);

            foreach (string actionName in first.Actions.Distinct(StringComparer.OrdinalIgnoreCase))
            {
                int actionId = await db.ExecuteScalarAsync<int>(
                    "SELECT Id FROM Actions WHERE Name = @actionName", new { actionName }, tx);

                await db.ExecuteAsync(
                    "INSERT INTO RecipeStepActions (StepId, ActionId) VALUES (@stepId, @actionId) ON CONFLICT DO NOTHING",
                    new { stepId, actionId }, tx);
            }

            foreach (var item in group)
            {
                if (string.IsNullOrEmpty(item.Name)) continue; // sentinel for ingredient-less steps

                await db.ExecuteAsync(
                    "INSERT INTO Ingredients (Name) VALUES (@name) ON CONFLICT(Name) DO NOTHING",
                    new { name = item.Name }, tx);

                int ingredientId = await db.ExecuteScalarAsync<int>(
                    "SELECT Id FROM Ingredients WHERE Name = @name", new { name = item.Name }, tx);

                await db.ExecuteAsync(
                    """
                    INSERT INTO RecipeStepIngredients (StepId, IngredientId, Quantity, Unit)
                    VALUES (@stepId, @ingredientId, @quantity, @unit)
                    """,
                    new { stepId, ingredientId, quantity = item.Quantity, unit = item.Unit }, tx);
            }
        }
    }
}
