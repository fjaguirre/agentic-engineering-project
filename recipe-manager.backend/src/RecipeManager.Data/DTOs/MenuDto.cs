namespace RecipeManager.Data.DTOs;

public record MenuDto(
    int Id,
    int Seed,
    DateTime GeneratedAt,
    IReadOnlyList<MenuSlotDto> Slots);
