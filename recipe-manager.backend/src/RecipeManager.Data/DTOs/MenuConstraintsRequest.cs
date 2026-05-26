namespace RecipeManager.Data.DTOs;

public record MenuConstraintsRequest(
    IReadOnlyList<string> ExcludedTags,
    int DailyCalorieMin,
    int DailyCalorieMax,
    int Seed,
    int TargetServings);
