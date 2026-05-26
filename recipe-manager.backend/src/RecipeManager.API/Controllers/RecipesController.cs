using Microsoft.AspNetCore.Mvc;
using RecipeManager.Data.DTOs;
using RecipeManager.Service.Interfaces;

namespace RecipeManager.API.Controllers;

[ApiController]
[Route("api/recipes")]
public sealed class RecipesController(IRecipeService recipeService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await recipeService.GetAllAsync());

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id) =>
        Ok(await recipeService.GetByIdAsync(id));

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateRecipeRequest request)
    {
        int id = await recipeService.CreateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id }, new { id });
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateRecipeRequest request)
    {
        await recipeService.UpdateAsync(id, request);
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        await recipeService.DeleteAsync(id);
        return NoContent();
    }
}
