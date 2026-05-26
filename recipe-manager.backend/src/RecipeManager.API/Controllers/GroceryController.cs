using Microsoft.AspNetCore.Mvc;
using RecipeManager.Data.DTOs;
using RecipeManager.Service.Interfaces;

namespace RecipeManager.API.Controllers;

[ApiController]
[Route("api/menus/{menuId:int}/grocery")]
public sealed class GroceryController(IGroceryListService groceryListService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetForMenu(int menuId)
    {
        IReadOnlyList<GroceryLineItemDto> list = await groceryListService.GetForMenuAsync(menuId);
        return Ok(list);
    }
}
