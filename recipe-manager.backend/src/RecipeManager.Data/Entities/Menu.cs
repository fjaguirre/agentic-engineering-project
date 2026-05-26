namespace RecipeManager.Data.Entities;

public class Menu
{
    public int Id { get; init; }
    public int Seed { get; init; }
    public DateTime GeneratedAt { get; init; }

    public IReadOnlyList<MenuSlot> Slots { get; init; } = [];
}
