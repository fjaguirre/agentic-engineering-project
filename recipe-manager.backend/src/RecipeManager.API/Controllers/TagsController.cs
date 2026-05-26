using Microsoft.AspNetCore.Mvc;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.API.Controllers;

[ApiController]
[Route("api/tags")]
public sealed class TagsController(ITagRepository tagRepository) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        IReadOnlyList<Tag> tags = await tagRepository.GetAllAsync();
        return Ok(tags.Select(t => new { t.Id, t.Name }));
    }
}
