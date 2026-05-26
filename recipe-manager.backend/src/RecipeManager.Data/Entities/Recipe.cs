namespace RecipeManager.Data.Entities;

public class Recipe
{
    public int Id { get; init; }
    public string Title { get; init; } = string.Empty;
    public int Servings { get; init; }
    public int CaloriesPerServing { get; init; }
    public double ProteinG { get; init; }
    public double CarbsG { get; init; }
    public double FatG { get; init; }
    public string? PrimaryProtein { get; init; }
    public DateTime CreatedAt { get; init; }
    public DateTime UpdatedAt { get; init; }

    public IReadOnlyList<Tag> Tags { get; init; } = [];
    public IReadOnlyList<RecipeStep> Steps { get; init; } = [];
}
