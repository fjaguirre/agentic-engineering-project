using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.Extensions.DependencyInjection;
using RecipeManager.Data;
using RecipeManager.Repository;

namespace RecipeManager.Tests.Integration;

public sealed class IntegrationTestFactory : WebApplicationFactory<Program>
{
    // Named in-memory SQLite URI — unique per factory instance.
    private readonly string _dbName = $"file:{Guid.NewGuid():N}?mode=memory&cache=shared";

    // Keep one connection open for the lifetime of this factory so the in-memory
    // database is not destroyed when DbUp closes its migration connections.
    private readonly SqliteConnection _keepAlive;

    public IntegrationTestFactory()
    {
        _keepAlive = new SqliteConnection($"Data Source={_dbName}");
        _keepAlive.Open();
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Replace the real SqliteConnectionFactory with one pointing to the in-memory DB
            ServiceDescriptor? existing = services.SingleOrDefault(
                d => d.ServiceType == typeof(SqliteConnectionFactory));
            if (existing is not null)
                services.Remove(existing);

            string connectionString = $"Data Source={_dbName}";
            services.AddSingleton(new SqliteConnectionFactory(connectionString));
        });
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
            _keepAlive.Dispose();
        base.Dispose(disposing);
    }
}
