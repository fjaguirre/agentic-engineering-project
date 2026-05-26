namespace RecipeManager.Data.DTOs;

public record CreateRecipeRequest(
    string Title,
    int Servings,
    int CaloriesPerServing,
    double ProteinG,
    double CarbsG,
    double FatG,
    string? PrimaryProtein,
    IReadOnlyList<string> Tags,
    IReadOnlyList<CreateStepRequest> Steps);
