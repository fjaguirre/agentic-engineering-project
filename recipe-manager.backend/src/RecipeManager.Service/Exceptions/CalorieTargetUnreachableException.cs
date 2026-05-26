using RecipeManager.Data.Entities;

namespace RecipeManager.Service.Exceptions;

public sealed class CalorieTargetUnreachableException(int day, MealSlot slot, int min, int max, int retries)
    : InvalidOperationException(
        $"Could not satisfy calorie target [{min}–{max} kcal/day] on day {day} after {retries} retries. " +
        $"Last failed slot: {slot}. Add more recipes or widen the calorie window.");
