using RecipeManager.Data.Entities;

namespace RecipeManager.Repository.Interfaces;

public interface IIngredientRepository
{
    Task<int> GetOrCreateAsync(string name);
    Task<IReadOnlyList<Ingredient>> GetAllAsync();
}
