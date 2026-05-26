using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Tests.Unit.Fakes;

internal sealed class FakeMenuRepository : IMenuRepository
{
    private int _nextId = 1;

    public Task<Menu?> GetByIdAsync(int id) => Task.FromResult<Menu?>(null);
    public Task<IReadOnlyList<Menu>> GetAllAsync() => Task.FromResult<IReadOnlyList<Menu>>([]);
    public Task<int> SaveAsync(Menu menu) => Task.FromResult(_nextId++);
}
