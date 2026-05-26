namespace RecipeManager.Data.DTOs;

public record RecipeStepDto(
    int Id,
    int OrderIndex,
    IReadOnlyList<string> Actions,
    IReadOnlyList<RecipeStepIngredientDto> Ingredients,
    int? DurationMinutes,
    string? Notes);
