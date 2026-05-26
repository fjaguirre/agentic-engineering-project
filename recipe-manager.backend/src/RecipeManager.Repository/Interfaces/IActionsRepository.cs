using RecipeManager.Data.Entities;

namespace RecipeManager.Repository.Interfaces;

public interface IActionsRepository
{
    Task<IReadOnlyList<CulinaryAction>> GetAllAsync();
}
