using RecipeManager.Data.Entities;

namespace RecipeManager.Repository.Interfaces;

public interface ITagRepository
{
    Task<int> GetOrCreateAsync(string name);
    Task<IReadOnlyList<Tag>> GetAllAsync();
}
