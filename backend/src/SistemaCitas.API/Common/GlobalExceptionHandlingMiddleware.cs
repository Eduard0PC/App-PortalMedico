using System.Net;
using System.Text.Json;
using FluentValidation;
using SistemaCitas.Domain.Exceptions;

namespace SistemaCitas.API.Common;
public sealed class GlobalExceptionHandlingMiddleware : IMiddleware
{
    private readonly ILogger<GlobalExceptionHandlingMiddleware> _logger;

    public GlobalExceptionHandlingMiddleware(ILogger<GlobalExceptionHandlingMiddleware> logger) =>
        _logger = logger;

    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        try
        {
            await next(context);
        }
        catch (ValidationException ex)
        {
            var errores = ex.Errors
                .GroupBy(e => e.PropertyName)
                .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());

            await EscribirRespuesta(context, HttpStatusCode.BadRequest,
                "Uno o más campos no son válidos.", errores);
        }
        catch (CredencialesInvalidasException ex)
        {
            await EscribirRespuesta(context, HttpStatusCode.Unauthorized, ex.Message);
        }
        catch (AccesoDenegadoException ex)
        {
            await EscribirRespuesta(context, HttpStatusCode.Forbidden, ex.Message);
        }
        catch (NotFoundException ex)
        {
            await EscribirRespuesta(context, HttpStatusCode.NotFound, ex.Message);
        }
        catch (ConflictoDeConcurrenciaException ex)
        {
            await EscribirRespuesta(context, HttpStatusCode.Conflict, ex.Message);
        }
        catch (ReglaDeNegocioException ex)
        {
            await EscribirRespuesta(context, HttpStatusCode.BadRequest, ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Excepción no controlada");
            await EscribirRespuesta(context, HttpStatusCode.InternalServerError,
                "Ocurrió un error inesperado. Intentá de nuevo más tarde.");
        }
    }

    private static Task EscribirRespuesta(
        HttpContext context, HttpStatusCode statusCode, string mensaje, object? data = null)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        var respuesta = ApiResponse.Fail(mensaje, data);
        var json = JsonSerializer.Serialize(respuesta,
            new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });

        return context.Response.WriteAsync(json);
    }
}