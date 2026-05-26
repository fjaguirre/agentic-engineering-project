namespace RecipeManager.Data.Entities;

public class RecipeStepIngredient
{
    public int Id { get; init; }
    public int StepId { get; init; }
    public int IngredientId { get; init; }
    public string IngredientName { get; init; } = string.Empty;
    public double Quantity { get; init; }
    public string Unit { get; init; } = string.Empty;
}
