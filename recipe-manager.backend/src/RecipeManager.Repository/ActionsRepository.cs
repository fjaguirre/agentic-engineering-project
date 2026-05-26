using System.Data;
using Dapper;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Repository;

public sealed class ActionsRepository(SqliteConnectionFactory connectionFactory) : IActionsRepository
{
    public async Task<IReadOnlyList<CulinaryAction>> GetAllAsync()
    {
        using IDbConnection db = connectionFactory.Create();
        IEnumerable<CulinaryAction> rows = await db.QueryAsync<CulinaryAction>(
            "SELECT Id, Name FROM Actions ORDER BY Name");
        return rows.ToList();
    }
}
