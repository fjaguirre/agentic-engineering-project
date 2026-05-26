namespace RecipeManager.Data.Entities;

public class RecipeStep
{
    public int Id { get; init; }
    public int RecipeId { get; init; }
    public int OrderIndex { get; init; }
    public int? DurationMinutes { get; init; }
    public string? Notes { get; init; }

    public IReadOnlyList<CulinaryAction> Actions { get; init; } = [];
    public IReadOnlyList<RecipeStepIngredient> Ingredients { get; init; } = [];
}
