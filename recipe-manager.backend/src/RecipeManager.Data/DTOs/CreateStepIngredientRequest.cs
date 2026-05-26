namespace RecipeManager.Data.DTOs;

public record CreateStepIngredientRequest(
    string IngredientName,
    double Quantity,
    string Unit);
