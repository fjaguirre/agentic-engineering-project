namespace RecipeManager.Data.DTOs;

public record RecipeStepIngredientDto(
    int IngredientId,
    string IngredientName,
    double Quantity,
    string Unit);
