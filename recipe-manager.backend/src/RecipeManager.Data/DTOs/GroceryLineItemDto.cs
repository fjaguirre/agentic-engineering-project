namespace RecipeManager.Data.DTOs;

public record GroceryLineItemDto(
    string IngredientName,
    double Quantity,
    string Unit);
