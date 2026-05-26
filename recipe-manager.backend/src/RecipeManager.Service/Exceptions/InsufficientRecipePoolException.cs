namespace RecipeManager.Service.Exceptions;

public sealed class InsufficientRecipePoolException(int required, int actual)
    : InvalidOperationException(
        $"The recipe pool has {actual} recipes after applying exclusion filters, " +
        $"but at least {required} are needed to satisfy repetition constraints over 7 days.");
