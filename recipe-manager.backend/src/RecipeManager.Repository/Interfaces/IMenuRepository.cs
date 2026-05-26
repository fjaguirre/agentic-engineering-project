using RecipeManager.Data.Entities;

namespace RecipeManager.Repository.Interfaces;

public interface IMenuRepository
{
    Task<Menu?> GetByIdAsync(int id);
    Task<IReadOnlyList<Menu>> GetAllAsync();
    Task<int> SaveAsync(Menu menu);
}
