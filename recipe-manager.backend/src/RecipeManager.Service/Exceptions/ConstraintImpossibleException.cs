namespace RecipeManager.Service.Exceptions;

public sealed class ConstraintImpossibleException(string message)
    : InvalidOperationException(message);
