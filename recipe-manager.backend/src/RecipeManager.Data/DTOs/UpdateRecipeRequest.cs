namespace RecipeManager.Data.DTOs;

public record UpdateRecipeRequest(
    string Title,
    int Servings,
    int CaloriesPerServing,
    double ProteinG,
    double CarbsG,
    double FatG,
    string? PrimaryProtein,
    IReadOnlyList<string> Tags,
    IReadOnlyList<CreateStepRequest> Steps);
