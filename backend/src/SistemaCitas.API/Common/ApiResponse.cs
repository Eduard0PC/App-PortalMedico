namespace SistemaCitas.API.Common;

public sealed record ApiResponse(bool Success, object? Data, string Message)
{
    public static ApiResponse Ok(object? data, string message) => new(true, data, message);

    public static ApiResponse Fail(string message, object? data = null) => new(false, data, message);
}