using RecipeManager.API.Middleware;
using RecipeManager.Data;
using RecipeManager.Repository;
using RecipeManager.Repository.Interfaces;
using RecipeManager.Service;
using RecipeManager.Service.Interfaces;
using Serilog;

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft.AspNetCore", Serilog.Events.LogEventLevel.Warning)
    .WriteTo.Console()
    .WriteTo.File("logs/app-.log", rollingInterval: RollingInterval.Day, retainedFileCountLimit: 7)
    .CreateLogger();

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);
builder.Host.UseSerilog();

string dbPath = builder.Configuration["Database:Path"] ?? "recipe-manager.db";
string connectionString = $"Data Source={dbPath}";

builder.Services.AddSingleton(new SqliteConnectionFactory(connectionString));
builder.Services.AddScoped<IRecipeRepository, RecipeRepository>();
builder.Services.AddScoped<IIngredientRepository, IngredientRepository>();
builder.Services.AddScoped<ITagRepository, TagRepository>();
builder.Services.AddScoped<IActionsRepository, ActionsRepository>();
builder.Services.AddScoped<IMenuRepository, MenuRepository>();
builder.Services.AddScoped<IRecipeService, RecipeService>();
builder.Services.AddScoped<IMenuGeneratorService, MenuGeneratorService>();
builder.Services.AddScoped<IGroceryListService, GroceryListService>();

builder.Services.AddControllers();
builder.Services.AddCors(options =>
    options.AddDefaultPolicy(policy =>
        policy.WithOrigins(builder.Configuration["Cors:AllowedOrigin"] ?? "http://localhost:5173")
              .AllowAnyHeader()
              .AllowAnyMethod()));

WebApplication app = builder.Build();

// Use the DI-registered factory so integration tests can substitute their own connection string.
string migrateConnectionString = app.Services.GetRequiredService<SqliteConnectionFactory>().ConnectionString;
DatabaseBootstrapper.MigrateUp(migrateConnectionString);

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors();
if (!app.Environment.IsDevelopment())
    app.UseHttpsRedirection();
app.MapControllers();

app.Run();

// Expose Program for WebApplicationFactory in integration tests
public partial class Program { }
