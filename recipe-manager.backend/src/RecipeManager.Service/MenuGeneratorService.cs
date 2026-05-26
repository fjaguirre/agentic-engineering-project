using RecipeManager.Data.DTOs;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;
using RecipeManager.Service.Exceptions;
using RecipeManager.Service.Interfaces;

namespace RecipeManager.Service;

public sealed class MenuGeneratorService(
    IRecipeRepository recipeRepository,
    IMenuRepository menuRepository) : IMenuGeneratorService
{
    private const int Days = 7;
    private const int MaxRetries = 50;

    private static readonly MealSlot[] SlotOrder =
        [MealSlot.Breakfast, MealSlot.Lunch, MealSlot.Dinner];

    public async Task<MenuDto> GenerateAsync(MenuConstraintsRequest constraints)
    {
        IReadOnlyList<Recipe> allRecipes = await recipeRepository.GetAllAsync();

        // --- Exclusion filter (binary — applied once, permanent) ---
        List<Recipe> pool = allRecipes
            .Where(r => !r.Tags.Any(t =>
                constraints.ExcludedTags.Contains(t.Name, StringComparer.OrdinalIgnoreCase)))
            .ToList();

        if (pool.Count == 0)
            throw new ConstraintImpossibleException(
                "All recipes were excluded by the provided dietary restriction tags. " +
                "Add recipes that do not contain the excluded tags.");

        // The 3-day window spans 9 slots (3 days × 3 meal slots). The algorithm needs at least
        // windowSize + 1 = 10 recipes so there is always at least 1 candidate outside the window.
        const int MinPoolSize = 10;
        if (pool.Count < MinPoolSize)
            throw new InsufficientRecipePoolException(required: MinPoolSize, actual: pool.Count);

        // --- Deterministic seed — single instance, passed through the entire loop ---
        Random rng = new(constraints.Seed);

        List<MenuSlot> slots = [];
        List<int> placedRecipeIds = [];        // ordered list of placed recipe IDs (for repetition window)
        Dictionary<int, string?> dayProtein = []; // day -> primary protein placed that day

        for (int day = 1; day <= Days; day++)
        {
            int dailyCalories = 0;

            foreach (MealSlot slot in SlotOrder)
            {
                Recipe selected = SelectRecipe(
                    pool, placedRecipeIds, dayProtein, day, slot,
                    constraints, dailyCalories, rng);

                slots.Add(new MenuSlot
                {
                    Day = day,
                    MealSlot = slot,
                    RecipeId = selected.Id,
                    Recipe = selected,
                });

                placedRecipeIds.Add(selected.Id);
                dailyCalories += selected.CaloriesPerServing * constraints.TargetServings;

                // Track protein for variety constraint
                if (selected.PrimaryProtein is not null)
                    dayProtein[day] = selected.PrimaryProtein;
            }

            // Post-day calorie window assertion (last resort guard — the slot loop already enforces it)
            if (dailyCalories < constraints.DailyCalorieMin || dailyCalories > constraints.DailyCalorieMax)
                throw new CalorieTargetUnreachableException(
                    day, SlotOrder.Last(), constraints.DailyCalorieMin, constraints.DailyCalorieMax, MaxRetries);
        }

        Menu menu = new()
        {
            Seed = constraints.Seed,
            Slots = slots,
        };

        int menuId = await menuRepository.SaveAsync(menu);

        return new MenuDto(
            menuId,
            constraints.Seed,
            DateTime.UtcNow,
            slots.Select(s => new MenuSlotDto(
                s.Day,
                s.MealSlot.ToString(),
                MapRecipeToDto(s.Recipe!))).ToList());
    }

    private static Recipe SelectRecipe(
        List<Recipe> pool,
        List<int> placedIds,
        Dictionary<int, string?> dayProtein,
        int day,
        MealSlot slot,
        MenuConstraintsRequest constraints,
        int currentDailyCalories,
        Random rng)
    {
        // Remaining calorie budget after this slot: we need room for the slots still to come
        int slotsRemaining = SlotOrder.Length - Array.IndexOf(SlotOrder, slot) - 1;

        for (int attempt = 0; attempt < MaxRetries; attempt++)
        {
            List<Recipe> candidates = pool
                .Where(r => PassesRepetitionGuard(r.Id, placedIds, day))
                .Where(r => PassesProteinVariety(r, dayProtein, day))
                .ToList();

            if (candidates.Count == 0)
                throw new ConstraintImpossibleException(
                    $"No eligible recipes remain for day {day} {slot} after applying all constraints. " +
                    "Expand the recipe pool or relax the repetition/protein constraints.");

            Recipe candidate = candidates[rng.Next(0, candidates.Count)];
            int slotCalories = candidate.CaloriesPerServing * constraints.TargetServings;
            int projectedDaily = currentDailyCalories + slotCalories;

            // For the last slot of the day enforce the window strictly
            if (slotsRemaining == 0)
            {
                if (projectedDaily >= constraints.DailyCalorieMin &&
                    projectedDaily <= constraints.DailyCalorieMax)
                    return candidate;
                continue;
            }

            // For earlier slots allow any calorie value — the window is enforced at day close
            return candidate;
        }

        throw new CalorieTargetUnreachableException(
            day, slot, constraints.DailyCalorieMin, constraints.DailyCalorieMax, MaxRetries);
    }

    // A recipe cannot appear within the previous 3 placements (3-day rolling window).
    private static bool PassesRepetitionGuard(int recipeId, List<int> placedIds, int day)
    {
        if (day == 1) return true;
        int windowSize = Math.Min(3 * SlotOrder.Length, placedIds.Count);
        return !placedIds.TakeLast(windowSize).Contains(recipeId);
    }

    // The same primary protein cannot dominate consecutive days.
    private static bool PassesProteinVariety(Recipe recipe, Dictionary<int, string?> dayProtein, int day)
    {
        if (recipe.PrimaryProtein is null) return true;
        if (!dayProtein.TryGetValue(day - 1, out string? prevProtein)) return true;
        return !string.Equals(recipe.PrimaryProtein, prevProtein, StringComparison.OrdinalIgnoreCase);
    }

    private static RecipeDto MapRecipeToDto(Recipe r) => new(
        r.Id, r.Title, r.Servings, r.CaloriesPerServing,
        r.ProteinG, r.CarbsG, r.FatG, r.PrimaryProtein,
        r.Tags.Select(t => new TagDto(t.Id, t.Name)).ToList(),
        []);
}
