using RecipeManager.Data.DTOs;

namespace RecipeManager.Service.Interfaces;

public interface IGroceryListService
{
    Task<IReadOnlyList<GroceryLineItemDto>> GetForMenuAsync(int menuId);
}
