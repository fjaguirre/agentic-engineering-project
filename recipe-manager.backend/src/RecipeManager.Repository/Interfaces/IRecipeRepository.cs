using RecipeManager.Data.Entities;

namespace RecipeManager.Repository.Interfaces;

public interface IRecipeRepository
{
    Task<IReadOnlyList<Recipe>> GetAllAsync();
    Task<Recipe?> GetByIdAsync(int id);
    Task<int> CreateAsync(Recipe recipe, IReadOnlyList<string> tagNames, IReadOnlyList<(string Name, double Quantity, string Unit, int StepOrderIndex, IReadOnlyList<string> Actions, int? DurationMinutes, string? Notes)> stepIngredients);
    Task UpdateAsync(int id, Recipe recipe, IReadOnlyList<string> tagNames, IReadOnlyList<(string Name, double Quantity, string Unit, int StepOrderIndex, IReadOnlyList<string> Actions, int? DurationMinutes, string? Notes)> stepIngredients);
    Task DeleteAsync(int id);
}
