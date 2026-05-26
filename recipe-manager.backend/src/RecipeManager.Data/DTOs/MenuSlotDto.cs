namespace RecipeManager.Data.DTOs;

public record MenuSlotDto(
    int Day,
    string MealSlot,
    RecipeDto Recipe);
