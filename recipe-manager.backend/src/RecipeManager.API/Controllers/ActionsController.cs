using Microsoft.AspNetCore.Mvc;
using RecipeManager.Data.Entities;
using RecipeManager.Repository.Interfaces;

namespace RecipeManager.API.Controllers;

[ApiController]
[Route("api/actions")]
public sealed class ActionsController(IActionsRepository actionsRepository) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        IReadOnlyList<CulinaryAction> actions = await actionsRepository.GetAllAsync();
        return Ok(actions.Select(a => new { a.Id, a.Name }));
    }
}
