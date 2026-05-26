using DbUp;
using DbUp.Engine;

namespace RecipeManager.Data;

public static class DatabaseBootstrapper
{
    public static void MigrateUp(string connectionString)
    {
        // SQLite creates the database file automatically on first connection.
        UpgradeEngine upgrader = DeployChanges.To
            .SqliteDatabase(connectionString)
            .WithScriptsEmbeddedInAssembly(typeof(DatabaseBootstrapper).Assembly)
            .WithTransactionPerScript()
            .LogToConsole()
            .Build();

        DatabaseUpgradeResult result = upgrader.PerformUpgrade();

        if (!result.Successful)
            throw new InvalidOperationException(
                $"Database migration failed: {result.Error.Message}", result.Error);
    }
}
