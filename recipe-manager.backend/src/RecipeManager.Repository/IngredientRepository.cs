using System.Data;
using Dapper;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.Repository;

public sealed class IngredientRepository(SqliteConnectionFactory connectionFactory) : IIngredientRepository
{
    public async Task<int> GetOrCreateAsync(string name)
    {
        using IDbConnection db = connectionFactory.Create();
        await db.ExecuteAsync(
            "INSERT INTO Ingredients (Name) VALUES (@name) ON CONFLICT(Name) DO NOTHING",
            new { name });
        return await db.ExecuteScalarAsync<int>(
            "SELECT Id FROM Ingredients WHERE Name = @name", new { name });
    }

    public async Task<IReadOnlyList<Ingredient>> GetAllAsync()
    {
        using IDbConnection db = connectionFactory.Create();
        IEnumerable<Ingredient> ingredients = await db.QueryAsync<Ingredient>(
            "SELECT Id, Name FROM Ingredients ORDER BY Name");
        return ingredients.ToList();
    }
}
