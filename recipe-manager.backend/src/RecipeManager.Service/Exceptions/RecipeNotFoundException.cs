namespace RecipeManager.Service.Exceptions;

public sealed class RecipeNotFoundException(int id)
    : KeyNotFoundException($"Recipe with id {id} was not found.");
