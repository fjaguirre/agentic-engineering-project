namespace RecipeManager.Data.DTOs;

public record RecipeDto(
    int Id,
    string Title,
    int Servings,
    int CaloriesPerServing,
    double ProteinG,
    double CarbsG,
    double FatG,
    string? PrimaryProtein,
    IReadOnlyList<TagDto> Tags,
    IReadOnlyList<RecipeStepDto> Steps);
