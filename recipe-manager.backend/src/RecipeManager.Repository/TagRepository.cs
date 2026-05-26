using System.Data;
using Dapper;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Repository;

public sealed class TagRepository(SqliteConnectionFactory connectionFactory) : ITagRepository
{
    public async Task<int> GetOrCreateAsync(string name)
    {
        using IDbConnection db = connectionFactory.Create();
        await db.ExecuteAsync(
            "INSERT INTO Tags (Name) VALUES (@name) ON CONFLICT(Name) DO NOTHING",
            new { name });
        return await db.ExecuteScalarAsync<int>(
            "SELECT Id FROM Tags WHERE Name = @name", new { name });
    }

    public async Task<IReadOnlyList<Tag>> GetAllAsync()
    {
        using IDbConnection db = connectionFactory.Create();
        IEnumerable<Tag> tags = await db.QueryAsync<Tag>("SELECT Id, Name FROM Tags ORDER BY Name");
        return tags.ToList();
    }
}
