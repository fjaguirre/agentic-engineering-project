using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using RecipeManager.Data.DTOs;

namespace RecipeManager.Tests.Integration;

public sealed class MenuPipelineTests(IntegrationTestFactory factory)
    : IClassFixture<IntegrationTestFactory>
{
    private readonly HttpClient _client = factory.CreateClient();

    private static CreateRecipeRequest MakeRecipe(string title, int calories, string protein, string tag) =>
        new(
            Title: title,
            Servings: 2,
            CaloriesPerServing: calories,
            ProteinG: 30,
            CarbsG: 40,
            FatG: 12,
            PrimaryProtein: protein,
            Tags: [tag],
            Steps:
            [
                new CreateStepRequest(
                    OrderIndex: 1,
                    Actions: ["Mix"],
                    Ingredients: [new CreateStepIngredientRequest(protein, 150, "g")],
                    DurationMinutes: 10,
                    Notes: null)
            ]);

    private async Task SeedMinimumPool()
    {
        // Seed 10 distinct recipes (MinPoolSize = 10) using varied proteins and a common tag
        string[] proteins = ["Chicken", "Beef", "Tofu", "Fish", "Pork", "Lamb", "Turkey", "Shrimp", "Eggs", "Beans"];
        for (int i = 0; i < proteins.Length; i++)
        {
            HttpResponseMessage r = await _client.PostAsJsonAsync("/api/recipes",
                MakeRecipe($"Pipeline Recipe {i + 1}", 600 + i * 10, proteins[i], "Pipeline"));
            r.EnsureSuccessStatusCode();
        }
    }

    [Fact]
    public async Task GenerateMenu_Returns201_WithCorrectSlotCount()
    {
        // Arrange
        await SeedMinimumPool();
        MenuConstraintsRequest constraints = new(
            ExcludedTags: [],
            DailyCalorieMin: 0,
            DailyCalorieMax: int.MaxValue,
            Seed: 42,
            TargetServings: 1);

        // Act
        HttpResponseMessage response = await _client.PostAsJsonAsync("/api/menus/generate", constraints);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        MenuDto? menu = await response.Content.ReadFromJsonAsync<MenuDto>();
        menu.Should().NotBeNull();
        menu!.Slots.Should().HaveCount(21);
    }

    [Fact]
    public async Task GenerateMenu_IsDeterministic_ForSameSeed()
    {
        // Arrange
        await SeedMinimumPool();
        MenuConstraintsRequest constraints = new(
            ExcludedTags: [],
            DailyCalorieMin: 0,
            DailyCalorieMax: int.MaxValue,
            Seed: 77,
            TargetServings: 1);

        // Act
        HttpResponseMessage r1 = await _client.PostAsJsonAsync("/api/menus/generate", constraints);
        HttpResponseMessage r2 = await _client.PostAsJsonAsync("/api/menus/generate", constraints);
        MenuDto? m1 = await r1.Content.ReadFromJsonAsync<MenuDto>();
        MenuDto? m2 = await r2.Content.ReadFromJsonAsync<MenuDto>();

        // Assert
        m1.Should().NotBeNull();
        m2.Should().NotBeNull();
        for (int i = 0; i < 21; i++)
            m1!.Slots[i].Recipe.Id.Should().Be(m2!.Slots[i].Recipe.Id,
                because: $"slot {i} must be identical for seed 77");
    }

    [Fact]
    public async Task GetGroceryList_AfterMenuGeneration_ReturnsNonEmptyList()
    {
        // Arrange
        await SeedMinimumPool();
        MenuConstraintsRequest constraints = new(
            ExcludedTags: [],
            DailyCalorieMin: 0,
            DailyCalorieMax: int.MaxValue,
            Seed: 55,
            TargetServings: 2);

        HttpResponseMessage genResponse = await _client.PostAsJsonAsync("/api/menus/generate", constraints);
        genResponse.EnsureSuccessStatusCode();
        MenuDto? menu = await genResponse.Content.ReadFromJsonAsync<MenuDto>();
        menu.Should().NotBeNull();

        // Act
        HttpResponseMessage groceryResponse = await _client.GetAsync($"/api/menus/{menu!.Id}/grocery");

        // Assert
        groceryResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        IReadOnlyList<GroceryLineItemDto>? items =
            await groceryResponse.Content.ReadFromJsonAsync<IReadOnlyList<GroceryLineItemDto>>();
        items.Should().NotBeNull();
        items!.Should().NotBeEmpty(because: "each menu slot has at least one ingredient");
        items.Should().OnlyContain(item => item.Quantity > 0,
            because: "all consolidated quantities must be positive");
    }

    [Fact]
    public async Task GetMenuById_AfterGeneration_ReturnsPersistedMenu()
    {
        // Arrange
        await SeedMinimumPool();
        MenuConstraintsRequest constraints = new(
            ExcludedTags: [],
            DailyCalorieMin: 0,
            DailyCalorieMax: int.MaxValue,
            Seed: 11,
            TargetServings: 1);

        HttpResponseMessage genResponse = await _client.PostAsJsonAsync("/api/menus/generate", constraints);
        genResponse.EnsureSuccessStatusCode();
        MenuDto? created = await genResponse.Content.ReadFromJsonAsync<MenuDto>();
        created.Should().NotBeNull();

        // Act
        HttpResponseMessage getResponse = await _client.GetAsync($"/api/menus/{created!.Id}");

        // Assert
        getResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        MenuDto? fetched = await getResponse.Content.ReadFromJsonAsync<MenuDto>();
        fetched.Should().NotBeNull();
        fetched!.Id.Should().Be(created.Id);
        fetched.Slots.Should().HaveCount(21);
        fetched.Seed.Should().Be(11);
    }
}
