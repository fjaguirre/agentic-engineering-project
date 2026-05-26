using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Tests.Unit.Fakes;

internal sealed class FakeRecipeRepository(IReadOnlyList<Recipe> recipes) : IRecipeRepository
{
    public Task<IReadOnlyList<Recipe>> GetAllAsync() => Task.FromResult(recipes);
    public Task<Recipe?> GetByIdAsync(int id) => Task.FromResult(recipes.FirstOrDefault(r => r.Id == id));
    public Task<int> CreateAsync(Recipe recipe, IReadOnlyList<string> tagNames,
        IReadOnlyList<(string, double, string, int, IReadOnlyList<string>, int?, string?)> stepIngredients)
        => Task.FromResult(1);
    public Task UpdateAsync(int id, Recipe recipe, IReadOnlyList<string> tagNames,
        IReadOnlyList<(string, double, string, int, IReadOnlyList<string>, int?, string?)> stepIngredients)
        => Task.CompletedTask;
    public Task DeleteAsync(int id) => Task.CompletedTask;
}
