using RecipeManager.Data.DTOs;

namespace RecipeManager.Service.Interfaces;

public interface IMenuGeneratorService
{
    Task<MenuDto> GenerateAsync(MenuConstraintsRequest constraints);
}
