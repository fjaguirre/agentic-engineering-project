namespace RecipeManager.Data.Entities;

public enum MealSlot { Breakfast, Lunch, Dinner }

public class MenuSlot
{
    public int Id { get; init; }
    public int MenuId { get; init; }
    public int Day { get; init; }
    public MealSlot MealSlot { get; init; }
    public int RecipeId { get; init; }
    public Recipe? Recipe { get; init; }
}
