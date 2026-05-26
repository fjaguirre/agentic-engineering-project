using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Tests.Unit.Fakes;

internal sealed class FakeMenuRepositoryWithData(Menu menu) : IMenuRepository
{
    public Task<Menu?> GetByIdAsync(int id) =>
        Task.FromResult<Menu?>(menu.Id == id ? menu : null);

    public Task<IReadOnlyList<Menu>> GetAllAsync() =>
        Task.FromResult<IReadOnlyList<Menu>>([menu]);

    public Task<int> SaveAsync(Menu m) => Task.FromResult(m.Id);
}
