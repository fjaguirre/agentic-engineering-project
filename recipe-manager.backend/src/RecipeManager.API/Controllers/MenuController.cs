using Microsoft.AspNetCore.Mvc;
using RecipeManager.Data.DTOs;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;
using RecipeManager.Service.Interfaces;

namespace RecipeManager.API.Controllers;

[ApiController]
[Route("api/menus")]
public sealed class MenuController(
    IMenuGeneratorService menuGeneratorService,
    IMenuRepository menuRepository) : ControllerBase
{
    [HttpPost("generate")]
    public async Task<IActionResult> Generate([FromBody] MenuConstraintsRequest request)
    {
        MenuDto menu = await menuGeneratorService.GenerateAsync(request);
        return CreatedAtAction(nameof(GetById), new { id = menu.Id }, menu);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        Menu? menu = await menuRepository.GetByIdAsync(id);
        if (menu is null) return NotFound(new { status = 404, detail = $"Menu with id {id} was not found." });
        return Ok(MapToDto(menu));
    }

    [HttpGet]
    public async Task<IActionResult> GetAll() =>
        Ok(await menuRepository.GetAllAsync());

    private static MenuDto MapToDto(Menu menu) => new(
        menu.Id,
        menu.Seed,
        menu.GeneratedAt,
        menu.Slots.Select(s => new MenuSlotDto(
            s.Day,
            s.MealSlot.ToString(),
            new RecipeDto(
                s.Recipe!.Id, s.Recipe.Title, s.Recipe.Servings, s.Recipe.CaloriesPerServing,
                s.Recipe.ProteinG, s.Recipe.CarbsG, s.Recipe.FatG, s.Recipe.PrimaryProtein,
                s.Recipe.Tags.Select(t => new TagDto(t.Id, t.Name)).ToList(),
                []))).ToList());
}
