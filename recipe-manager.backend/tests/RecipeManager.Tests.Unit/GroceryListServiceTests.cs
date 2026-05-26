using FluentAssertions;
using RecipeManager.Data.DTOs;
using RecipeManager.Data.Entities;
using RecipeManager.Service;

namespace RecipeManager.Tests.Unit;

public sealed class GroceryListServiceTests
{
    private static Menu BuildMenu(IReadOnlyList<MenuSlot> slots) =>
        new() { Id = 1, Seed = 1, GeneratedAt = DateTime.UtcNow, Slots = slots };

    private static Recipe BuildRecipe(int id, int servings, IReadOnlyList<(string Name, double Qty, string Unit)> ingredients)
    {
        var stepIngredients = ingredients
            .Select((ing, idx) => new RecipeStepIngredient
            {
                Id = idx + 1,
                StepId = 1,
                IngredientId = idx + 1,
                IngredientName = ing.Name,
                Quantity = ing.Qty,
                Unit = ing.Unit,
            })
            .ToList();

        return new Recipe
        {
            Id = id,
            Title = $"Recipe {id}",
            Servings = servings,
            CaloriesPerServing = 500,
            Tags = [],
            Steps =
            [
                new RecipeStep
                {
                    Id = 1,
                    RecipeId = id,
                    OrderIndex = 1,
                    Actions = [],
                    Ingredients = stepIngredients,
                }
            ],
        };
    }

    private static GroceryListService BuildService(Menu menu)
    {
        var fakeMenuRepo = new Fakes.FakeMenuRepositoryWithData(menu);
        return new GroceryListService(fakeMenuRepo);
    }

    // --- Unit-matching sum ---

    [Fact]
    public async Task GivenSameIngredientAndUnit_WhenConsolidating_ThenQuantitiesAreSummed()
    {
        // Arrange
        Recipe recipe = BuildRecipe(1, servings: 1, [("Rice", 200, "g"), ("Rice", 300, "g")]);
        Menu menu = BuildMenu([new MenuSlot { Day = 1, MealSlot = MealSlot.Breakfast, RecipeId = 1, Recipe = recipe }]);

        // Act
        IReadOnlyList<GroceryLineItemDto> result = await BuildService(menu).GetForMenuAsync(1);

        // Assert
        result.Should().ContainSingle(item => item.IngredientName == "Rice" && item.Unit == "g")
            .Which.Quantity.Should().BeApproximately(500, 0.001);
    }

    // --- Incompatible unit separation ---

    [Fact]
    public async Task GivenSameIngredientDifferentUnits_WhenConsolidating_ThenListedAsSeparateLineItems()
    {
        // Arrange
        Recipe r1 = BuildRecipe(1, servings: 1, [("Garlic", 2, "cloves")]);
        Recipe r2 = BuildRecipe(2, servings: 1, [("Garlic", 10, "g")]);
        Menu menu = BuildMenu(
        [
            new MenuSlot { Day = 1, MealSlot = MealSlot.Breakfast, RecipeId = 1, Recipe = r1 },
            new MenuSlot { Day = 1, MealSlot = MealSlot.Lunch,     RecipeId = 2, Recipe = r2 },
        ]);

        // Act
        IReadOnlyList<GroceryLineItemDto> result = await BuildService(menu).GetForMenuAsync(1);

        // Assert — two separate lines for Garlic, not summed
        result.Where(i => i.IngredientName == "Garlic").Should().HaveCount(2,
            because: "incompatible units must not be summed");
        result.Should().Contain(i => i.IngredientName == "Garlic" && i.Unit == "cloves" && i.Quantity == 2);
        result.Should().Contain(i => i.IngredientName == "Garlic" && i.Unit == "g" && i.Quantity == 10);
    }

    // --- Scale factor ---

    [Fact]
    public async Task GivenRecipeWith2Servings_WhenConsolidating_ThenQuantityIsScaledTo1Serving()
    {
        // Arrange — recipe has 2 servings, ingredient is 400g; scaled to 1 serving = 200g
        Recipe recipe = BuildRecipe(1, servings: 2, [("Pasta", 400, "g")]);
        Menu menu = BuildMenu([new MenuSlot { Day = 1, MealSlot = MealSlot.Breakfast, RecipeId = 1, Recipe = recipe }]);

        // Act
        IReadOnlyList<GroceryLineItemDto> result = await BuildService(menu).GetForMenuAsync(1);

        // Assert
        result.Should().ContainSingle(i => i.IngredientName == "Pasta")
            .Which.Quantity.Should().BeApproximately(200, 0.001);
    }

    // --- Output ordering ---

    [Fact]
    public async Task GivenMultipleIngredients_WhenConsolidating_ThenResultIsAlphabeticallySorted()
    {
        // Arrange
        Recipe recipe = BuildRecipe(1, servings: 1, [("Zucchini", 1, "piece"), ("Apple", 2, "piece"), ("Mango", 3, "piece")]);
        Menu menu = BuildMenu([new MenuSlot { Day = 1, MealSlot = MealSlot.Breakfast, RecipeId = 1, Recipe = recipe }]);

        // Act
        IReadOnlyList<GroceryLineItemDto> result = await BuildService(menu).GetForMenuAsync(1);

        // Assert
        result.Select(i => i.IngredientName).Should().BeInAscendingOrder(StringComparer.OrdinalIgnoreCase);
    }
}
