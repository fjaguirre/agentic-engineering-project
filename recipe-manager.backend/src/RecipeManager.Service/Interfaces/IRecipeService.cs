using RecipeManager.Data.DTOs;

namespace RecipeManager.Service.Interfaces;

public interface IRecipeService
{
    Task<IReadOnlyList<RecipeDto>> GetAllAsync();
    Task<RecipeDto> GetByIdAsync(int id);
    Task<int> CreateAsync(CreateRecipeRequest request);
    Task UpdateAsync(int id, UpdateRecipeRequest request);
    Task DeleteAsync(int id);
}
