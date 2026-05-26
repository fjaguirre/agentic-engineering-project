using RecipeManager.Data.DTOs;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;
using RecipeManager.Service.Exceptions;
using RecipeManager.Service.Interfaces;

namespace RecipeManager.Service;

public sealed class GroceryListService(IMenuRepository menuRepository) : IGroceryListService
{
    public async Task<IReadOnlyList<GroceryLineItemDto>> GetForMenuAsync(int menuId)
    {
        Menu? menu = await menuRepository.GetByIdAsync(menuId);
        if (menu is null)
            throw new KeyNotFoundException($"Menu with id {menuId} was not found.");

        // Key = (IngredientName, Unit) — unit-sensitive grouping per PRD §3.3
        var accumulator = new Dictionary<(string Name, string Unit), double>(
            StringComparer.OrdinalIgnoreCase.Equals(default, default)
                ? EqualityComparer<(string, string)>.Default
                : new IngredientUnitComparer());

        foreach (MenuSlot slot in menu.Slots)
        {
            Recipe? recipe = slot.Recipe;
            if (recipe is null) continue;

            double scaleFactor = recipe.Servings > 0 ? 1.0 / recipe.Servings : 1.0;

            foreach (RecipeStep step in recipe.Steps)
            {
                foreach (RecipeStepIngredient ingredient in step.Ingredients)
                {
                    var key = (ingredient.IngredientName, ingredient.Unit);
                    double scaled = ingredient.Quantity * scaleFactor;

                    if (accumulator.TryGetValue(key, out double existing))
                        accumulator[key] = existing + scaled;
                    else
                        accumulator[key] = scaled;
                }
            }
        }

        return accumulator
            .Select(kv => new GroceryLineItemDto(kv.Key.Name, Math.Round(kv.Value, 3), kv.Key.Unit))
            .OrderBy(item => item.IngredientName, StringComparer.OrdinalIgnoreCase)
            .ThenBy(item => item.Unit, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private sealed class IngredientUnitComparer : IEqualityComparer<(string Name, string Unit)>
    {
        public bool Equals((string Name, string Unit) x, (string Name, string Unit) y) =>
            string.Equals(x.Name, y.Name, StringComparison.OrdinalIgnoreCase) &&
            string.Equals(x.Unit, y.Unit, StringComparison.OrdinalIgnoreCase);

        public int GetHashCode((string Name, string Unit) obj) =>
            HashCode.Combine(
                obj.Name.ToLowerInvariant(),
                obj.Unit.ToLowerInvariant());
    }
}
