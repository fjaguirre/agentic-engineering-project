using FluentAssertions;
using RecipeManager.Data.DTOs;
using RecipeManager.Data.Entities;
using RecipeManager.Service;
using RecipeManager.Service.Exceptions;
using RecipeManager.Tests.Unit.Fakes;
using RecipeManager.Tests.Unit.Helpers;

namespace RecipeManager.Tests.Unit;

public sealed class MenuGeneratorServiceTests
{
    private static MenuConstraintsRequest DefaultConstraints(int seed = 42) =>
        new(ExcludedTags: [], DailyCalorieMin: 0, DailyCalorieMax: int.MaxValue, Seed: seed, TargetServings: 1);

    private static MenuGeneratorService Build(IReadOnlyList<Recipe> pool) =>
        new(new FakeRecipeRepository(pool), new FakeMenuRepository());

    // --- Determinism ---

    [Fact]
    public async Task GivenSameSeedAndPool_WhenGeneratingTwice_ThenMenusAreIdentical()
    {
        // Arrange
        List<Recipe> pool = RecipeBuilder.BuildPool(10);
        MenuGeneratorService sut = Build(pool);
        MenuConstraintsRequest constraints = DefaultConstraints(seed: 99);

        // Act
        MenuDto first = await sut.GenerateAsync(constraints);
        MenuDto second = await sut.GenerateAsync(constraints);

        // Assert
        first.Slots.Should().HaveCount(21);
        second.Slots.Should().HaveCount(21);

        for (int i = 0; i < 21; i++)
        {
            first.Slots[i].Day.Should().Be(second.Slots[i].Day);
            first.Slots[i].MealSlot.Should().Be(second.Slots[i].MealSlot);
            first.Slots[i].Recipe.Id.Should().Be(second.Slots[i].Recipe.Id,
                because: $"slot {i} (day {first.Slots[i].Day} {first.Slots[i].MealSlot}) must be identical for the same seed");
        }
    }

    [Fact]
    public async Task GivenDifferentSeeds_WhenGeneratingWithSamePool_ThenMenusDiffer()
    {
        // Arrange
        List<Recipe> pool = RecipeBuilder.BuildPool(15);
        MenuGeneratorService sut = Build(pool);

        // Act
        MenuDto menuA = await sut.GenerateAsync(DefaultConstraints(seed: 1));
        MenuDto menuB = await sut.GenerateAsync(DefaultConstraints(seed: 2));

        // Assert — at least one slot must differ (statistically guaranteed with 15 recipes)
        bool anyDifference = menuA.Slots.Zip(menuB.Slots).Any(pair =>
            pair.First.Recipe.Id != pair.Second.Recipe.Id);
        anyDifference.Should().BeTrue(because: "different seeds must produce different menus");
    }

    // --- Exclusion constraint ---

    [Fact]
    public async Task GivenExcludedTag_WhenGenerating_ThenNoExcludedRecipeAppearsInMenu()
    {
        // Arrange
        // 2 Gluten recipes (excluded) + 12 eligible = pool of 12 after filtering (>= 10 required)
        List<Recipe> pool =
        [
            RecipeBuilder.Build(1, tags: ["Gluten"]),
            RecipeBuilder.Build(2, tags: ["Gluten"]),
            RecipeBuilder.Build(3, tags: ["Vegan"]),
            RecipeBuilder.Build(4, tags: ["Vegan"]),
            RecipeBuilder.Build(5, tags: ["Vegan"]),
            RecipeBuilder.Build(6),
            RecipeBuilder.Build(7),
            RecipeBuilder.Build(8),
            RecipeBuilder.Build(9),
            RecipeBuilder.Build(10),
            RecipeBuilder.Build(11),
            RecipeBuilder.Build(12),
            RecipeBuilder.Build(13),
            RecipeBuilder.Build(14),
        ];
        MenuConstraintsRequest constraints = DefaultConstraints() with { ExcludedTags = ["Gluten"] };

        // Act
        MenuDto menu = await Build(pool).GenerateAsync(constraints);

        // Assert — iterate ALL 21 slots
        foreach (MenuSlotDto slot in menu.Slots)
            slot.Recipe.Tags.Should().NotContain(t => t.Name == "Gluten",
                because: $"day {slot.Day} {slot.MealSlot} must not contain a Gluten-tagged recipe");
    }

    [Fact]
    public async Task GivenAllRecipesExcluded_WhenGenerating_ThenThrowsConstraintImpossibleException()
    {
        // Arrange
        List<Recipe> pool =
        [
            RecipeBuilder.Build(1, tags: ["Peanuts"]),
            RecipeBuilder.Build(2, tags: ["Peanuts"]),
        ];
        MenuConstraintsRequest constraints = DefaultConstraints() with { ExcludedTags = ["Peanuts"] };

        // Act
        Func<Task> act = async () => await Build(pool).GenerateAsync(constraints);

        // Assert
        await act.Should().ThrowAsync<ConstraintImpossibleException>();
    }

    // --- Recipe repetition ---

    [Fact]
    public async Task GivenRepetitionRule_WhenGenerating_ThenNoRecipeRepeatsWithin3Days()
    {
        // Arrange
        List<Recipe> pool = RecipeBuilder.BuildPool(20);

        // Act
        MenuDto menu = await Build(pool).GenerateAsync(DefaultConstraints());

        // Assert — for each slot, the same recipe must not appear in the previous 3 days
        for (int i = 9; i < menu.Slots.Count; i++) // start from day 4 to have a full 3-day window
        {
            int currentRecipeId = menu.Slots[i].Recipe.Id;
            int windowStart = i - 9; // 3 days × 3 slots
            for (int j = windowStart; j < i; j++)
            {
                menu.Slots[j].Recipe.Id.Should().NotBe(currentRecipeId,
                    because: $"slot {i} (day {menu.Slots[i].Day}) should not repeat recipe {currentRecipeId} found at slot {j}");
            }
        }
    }

    // --- Pool size guard ---

    [Fact]
    public async Task GivenPoolSmallerThan10_WhenGenerating_ThenThrowsInsufficientRecipePoolException()
    {
        // Arrange — 9 < MinPoolSize (10) so the guard must fire
        List<Recipe> pool = RecipeBuilder.BuildPool(9);

        // Act
        Func<Task> act = async () => await Build(pool).GenerateAsync(DefaultConstraints());

        // Assert
        await act.Should().ThrowAsync<InsufficientRecipePoolException>();
    }

    // --- Output shape ---

    [Fact]
    public async Task GivenValidPool_WhenGenerating_ThenMenuHas21Slots()
    {
        // Arrange
        List<Recipe> pool = RecipeBuilder.BuildPool(10);

        // Act
        MenuDto menu = await Build(pool).GenerateAsync(DefaultConstraints());

        // Assert
        menu.Slots.Should().HaveCount(21);
    }

    [Fact]
    public async Task GivenValidPool_WhenGenerating_ThenEachDayHasBreakfastLunchAndDinner()
    {
        // Arrange
        List<Recipe> pool = RecipeBuilder.BuildPool(10);

        // Act
        MenuDto menu = await Build(pool).GenerateAsync(DefaultConstraints());

        // Assert
        for (int day = 1; day <= 7; day++)
        {
            IEnumerable<MenuSlotDto> daySlots = menu.Slots.Where(s => s.Day == day);
            daySlots.Select(s => s.MealSlot).Should().Contain(["Breakfast", "Lunch", "Dinner"],
                because: $"day {day} must have all three meal slots");
        }
    }

    // --- Calorie window ---

    [Fact]
    public async Task GivenImpossibleCalorieWindow_WhenGenerating_ThenThrowsCalorieTargetUnreachableException()
    {
        // Arrange — each recipe has 650 kcal/serving, 3 meals = 1950 kcal/day; window [100-200] is impossible
        List<Recipe> pool = RecipeBuilder.BuildPool(10, caloriesEach: 650);
        MenuConstraintsRequest constraints = DefaultConstraints() with
        {
            DailyCalorieMin = 100,
            DailyCalorieMax = 200,
            TargetServings = 1
        };

        // Act
        Func<Task> act = async () => await Build(pool).GenerateAsync(constraints);

        // Assert
        await act.Should().ThrowAsync<CalorieTargetUnreachableException>();
    }
}
