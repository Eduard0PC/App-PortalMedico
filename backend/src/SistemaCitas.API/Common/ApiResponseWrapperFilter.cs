using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace SistemaCitas.API.Common;
public sealed class ApiResponseWrapperFilter : IAsyncResultFilter
{
    public async Task OnResultExecutionAsync(ResultExecutingContext context, ResultExecutionDelegate next)
    {
        if (context.Result is ObjectResult objectResult && objectResult.Value is not ApiResponse)
        {
            var mensaje = (objectResult.StatusCode ?? StatusCodes.Status200OK) switch
            {
                StatusCodes.Status201Created => "Recurso creado correctamente.",
                _ => "Operación exitosa."
            };

            objectResult.Value = ApiResponse.Ok(objectResult.Value, mensaje);
        }

        await next();
    }
}