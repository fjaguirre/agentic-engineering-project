using RecipeManager.Data.DTOs;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;
using RecipeManager.Service.Exceptions;
using RecipeManager.Service.Interfaces;

namespace RecipeManager.Service;

public sealed class RecipeService(IRecipeRepository recipeRepository) : IRecipeService
{
    public async Task<IReadOnlyList<RecipeDto>> GetAllAsync()
    {
        IReadOnlyList<Recipe> recipes = await recipeRepository.GetAllAsync();
        return recipes.Select(MapToDto).ToList();
    }

    public async Task<RecipeDto> GetByIdAsync(int id)
    {
        Recipe? recipe = await recipeRepository.GetByIdAsync(id);
        if (recipe is null) throw new RecipeNotFoundException(id);
        return MapToDto(recipe);
    }

    public async Task<int> CreateAsync(CreateRecipeRequest request)
    {
        ValidateRequest(request.Title, request.Servings, request.CaloriesPerServing);

        Recipe recipe = new()
        {
            Title = request.Title.Trim(),
            Servings = request.Servings,
            CaloriesPerServing = request.CaloriesPerServing,
            ProteinG = request.ProteinG,
            CarbsG = request.CarbsG,
            FatG = request.FatG,
            PrimaryProtein = request.PrimaryProtein?.Trim(),
        };

        var stepIngredients = FlattenSteps(request.Steps);

        return await recipeRepository.CreateAsync(recipe, request.Tags, stepIngredients);
    }

    public async Task UpdateAsync(int id, UpdateRecipeRequest request)
    {
        Recipe? existing = await recipeRepository.GetByIdAsync(id);
        if (existing is null) throw new RecipeNotFoundException(id);

        ValidateRequest(request.Title, request.Servings, request.CaloriesPerServing);

        Recipe updated = new()
        {
            Id = id,
            Title = request.Title.Trim(),
            Servings = request.Servings,
            CaloriesPerServing = request.CaloriesPerServing,
            ProteinG = request.ProteinG,
            CarbsG = request.CarbsG,
            FatG = request.FatG,
            PrimaryProtein = request.PrimaryProtein?.Trim(),
        };

        var stepIngredients = FlattenSteps(request.Steps);
        await recipeRepository.UpdateAsync(id, updated, request.Tags, stepIngredients);
    }

    public async Task DeleteAsync(int id)
    {
        Recipe? existing = await recipeRepository.GetByIdAsync(id);
        if (existing is null) throw new RecipeNotFoundException(id);
        await recipeRepository.DeleteAsync(id);
    }

    private static void ValidateRequest(string title, int servings, int calories)
    {
        if (string.IsNullOrWhiteSpace(title))
            throw new ArgumentException("Recipe title cannot be empty.");
        if (servings < 1)
            throw new ArgumentException("Servings must be at least 1.");
        if (calories < 0)
            throw new ArgumentException("Calories cannot be negative.");
    }

    private static IReadOnlyList<(string Name, double Quantity, string Unit, int StepOrderIndex, IReadOnlyList<string> Actions, int? DurationMinutes, string? Notes)>
        FlattenSteps(IReadOnlyList<CreateStepRequest> steps)
    {
        var result = new List<(string, double, string, int, IReadOnlyList<string>, int?, string?)>();

        foreach (CreateStepRequest step in steps)
        {
            if (step.Ingredients.Count == 0)
            {
                // Step with no ingredients — add a sentinel entry so the step is still created
                result.Add((string.Empty, 0, string.Empty, step.OrderIndex, step.Actions, step.DurationMinutes, step.Notes));
                continue;
            }

            foreach (CreateStepIngredientRequest ingredient in step.Ingredients)
            {
                result.Add((ingredient.IngredientName, ingredient.Quantity, ingredient.Unit,
                    step.OrderIndex, step.Actions, step.DurationMinutes, step.Notes));
            }
        }

        return result;
    }

    private static RecipeDto MapToDto(Recipe r) => new(
        r.Id,
        r.Title,
        r.Servings,
        r.CaloriesPerServing,
        r.ProteinG,
        r.CarbsG,
        r.FatG,
        r.PrimaryProtein,
        r.Tags.Select(t => new TagDto(t.Id, t.Name)).ToList(),
        r.Steps.Select(s => new RecipeStepDto(
            s.Id,
            s.OrderIndex,
            s.Actions.Select(a => a.Name).ToList(),
            s.Ingredients.Select(i => new RecipeStepIngredientDto(
                i.IngredientId, i.IngredientName, i.Quantity, i.Unit)).ToList(),
            s.DurationMinutes,
            s.Notes)).ToList());
}
