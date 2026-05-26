using System.Data;
using Microsoft.Data.Sqlite;

namespace RecipeManager.Repository;

public sealed class SqliteConnectionFactory(string connectionString)
{
    public string ConnectionString { get; } = connectionString;
    public IDbConnection Create() => new SqliteConnection(connectionString);
}
