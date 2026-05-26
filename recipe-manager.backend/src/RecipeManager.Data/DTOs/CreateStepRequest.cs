namespace RecipeManager.Data.DTOs;

public record CreateStepRequest(
    int OrderIndex,
    IReadOnlyList<string> Actions,
    IReadOnlyList<CreateStepIngredientRequest> Ingredients,
    int? DurationMinutes,
    string? Notes);
