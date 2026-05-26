using RecipeManager.Data.Entities;

namespace RecipeManager.Tests.Unit.Helpers;

internal static class RecipeBuilder
{
    public static Recipe Build(
        int id,
        string title = "Test Recipe",
        int calories = 500,
        string? primaryProtein = null,
        IReadOnlyList<string>? tags = null) =>
        new()
        {
            Id = id,
            Title = title,
            Servings = 1,
            CaloriesPerServing = calories,
            ProteinG = 20,
            CarbsG = 50,
            FatG = 10,
            PrimaryProtein = primaryProtein,
            Tags = tags?.Select(name => new Tag { Id = 0, Name = name }).ToList() ?? [],
            Steps = [],
        };

    public static List<Recipe> BuildPool(int count, int caloriesEach = 650) =>
        Enumerable.Range(1, count)
            .Select(i => Build(i, $"Recipe {i}", caloriesEach))
            .ToList();
}
