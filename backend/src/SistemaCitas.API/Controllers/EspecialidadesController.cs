using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Especialidades;
using SistemaCitas.Application.Especialidades.Commands.ActualizarEspecialidad;
using SistemaCitas.Application.Especialidades.Commands.CrearEspecialidad;
using SistemaCitas.Application.Especialidades.Commands.EliminarEspecialidad;
using SistemaCitas.Application.Especialidades.Queries.ListarEspecialidades;

namespace SistemaCitas.API.Controllers;

/// <summary>Body de PUT /api/especialidades/{id}: solo los campos editables, sin Id
/// (ese viene de la ruta y lo agrega el Controller antes de despachar el Command).</summary>
public sealed record ActualizarEspecialidadRequest(string Nombre, string? Descripcion);

[ApiController]
[Route("api/especialidades")]
public sealed class EspecialidadesController : ControllerBase
{
    private readonly ISender _sender;

    public EspecialidadesController(ISender sender) => _sender = sender;

    [Authorize(Roles = "Paciente,Administrador")]
    [HttpGet]
    public async Task<ActionResult<List<EspecialidadDto>>> Listar(CancellationToken ct)
        => Ok(await _sender.Send(new ListarEspecialidadesQuery(), ct));

    [Authorize(Roles = "Administrador")]
    [HttpPost]
    public async Task<ActionResult<EspecialidadDto>> Crear(
        CrearEspecialidadCommand command, CancellationToken ct)
    {
        var resultado = await _sender.Send(command, ct);
        return CreatedAtAction(nameof(Crear), resultado);
    }

    [Authorize(Roles = "Administrador")]
    [HttpPut("{id}")]
    public async Task<ActionResult<EspecialidadDto>> Actualizar(
        int id, ActualizarEspecialidadRequest request, CancellationToken ct)
    {
        var command = new ActualizarEspecialidadCommand(id, request.Nombre, request.Descripcion);
        var resultado = await _sender.Send(command, ct);
        return Ok(resultado);
    }

    [Authorize(Roles = "Administrador")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> Eliminar(int id, CancellationToken ct)
    {
        await _sender.Send(new EliminarEspecialidadCommand(id), ct);
        return NoContent();
    }
}