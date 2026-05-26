using System.Text.Json;
using RecipeManager.Service.Exceptions;

namespace RecipeManager.API.Middleware;

public sealed class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    private static readonly JsonSerializerOptions JsonOptions =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            await HandleAsync(context, ex);
        }
    }

    private async Task HandleAsync(HttpContext context, Exception ex)
    {
        int statusCode;
        string detail;

        switch (ex)
        {
            case ArgumentException:
                statusCode = StatusCodes.Status400BadRequest;
                detail = ex.Message;
                break;

            case KeyNotFoundException or RecipeNotFoundException:
                statusCode = StatusCodes.Status404NotFound;
                detail = ex.Message;
                break;

            case ConstraintImpossibleException
              or CalorieTargetUnreachableException
              or InsufficientRecipePoolException:
                statusCode = StatusCodes.Status422UnprocessableEntity;
                detail = ex.Message;
                break;

            default:
                statusCode = StatusCodes.Status500InternalServerError;
                detail = "An unexpected error occurred. Please try again later.";
                logger.LogError(ex, "Unhandled exception");
                break;
        }

        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";

        object body = new { status = statusCode, detail };
        await context.Response.WriteAsync(JsonSerializer.Serialize(body, JsonOptions));
    }
}
