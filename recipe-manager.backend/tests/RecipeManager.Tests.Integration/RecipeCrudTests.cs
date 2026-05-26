using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using RecipeManager.Data.DTOs;

namespace RecipeManager.Tests.Integration;

public sealed class RecipeCrudTests(IntegrationTestFactory factory)
    : IClassFixture<IntegrationTestFactory>
{
    private readonly HttpClient _client = factory.CreateClient();

    private static CreateRecipeRequest BasicRecipe(string title = "Integration Test Recipe") =>
        new(
            Title: title,
            Servings: 2,
            CaloriesPerServing: 400,
            ProteinG: 25,
            CarbsG: 45,
            FatG: 10,
            PrimaryProtein: "Chicken",
            Tags: ["GlutenFree"],
            Steps:
            [
                new CreateStepRequest(
                    OrderIndex: 1,
                    Actions: ["Chop"],
                    Ingredients: [new CreateStepIngredientRequest("Chicken Breast", 200, "g")],
                    DurationMinutes: 5,
                    Notes: "Dice into cubes")
            ]);

    [Fact]
    public async Task CreateRecipe_ReturnsCreated201()
    {
        // Arrange / Act
        HttpResponseMessage response = await _client.PostAsJsonAsync("/api/recipes", BasicRecipe());

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();
    }

    [Fact]
    public async Task CreateThenGetRecipe_ReturnsCorrectData()
    {
        // Arrange
        HttpResponseMessage createResponse = await _client.PostAsJsonAsync("/api/recipes", BasicRecipe("Pasta Primavera"));
        createResponse.EnsureSuccessStatusCode();
        string location = createResponse.Headers.Location!.ToString();
        int id = int.Parse(location.Split('/').Last());

        // Act
        HttpResponseMessage getResponse = await _client.GetAsync($"/api/recipes/{id}");

        // Assert
        getResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        RecipeDto? dto = await getResponse.Content.ReadFromJsonAsync<RecipeDto>();
        dto.Should().NotBeNull();
        dto!.Title.Should().Be("Pasta Primavera");
        dto.Tags.Should().ContainSingle(t => t.Name == "GlutenFree");
        dto.Steps.Should().ContainSingle(s => s.OrderIndex == 1);
    }

    [Fact]
    public async Task GetNonExistentRecipe_Returns404()
    {
        // Arrange / Act
        HttpResponseMessage response = await _client.GetAsync("/api/recipes/99999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task DeleteRecipe_Returns204_ThenGetReturns404()
    {
        // Arrange
        HttpResponseMessage createResponse = await _client.PostAsJsonAsync("/api/recipes", BasicRecipe("Delete Me"));
        createResponse.EnsureSuccessStatusCode();
        string location = createResponse.Headers.Location!.ToString();
        int id = int.Parse(location.Split('/').Last());

        // Act
        HttpResponseMessage deleteResponse = await _client.DeleteAsync($"/api/recipes/{id}");

        // Assert
        deleteResponse.StatusCode.Should().Be(HttpStatusCode.NoContent);
        HttpResponseMessage getResponse = await _client.GetAsync($"/api/recipes/{id}");
        getResponse.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }
}
