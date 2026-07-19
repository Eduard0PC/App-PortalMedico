using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Horarios;
using SistemaCitas.Application.Horarios.Commands.ActualizarHorario;
using SistemaCitas.Application.Horarios.Commands.CrearHorario;
using SistemaCitas.Application.Horarios.Commands.EliminarHorario;
using SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;
using SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

namespace SistemaCitas.API.Controllers;

/// <summary>Body de POST y PUT de /horario: solo los campos editables, sin Id ni IdMedico
/// (ambos vienen de la ruta y el Controller los agrega antes de despachar el Command).</summary>
public sealed record HorarioRequest(int DiaSemana, TimeOnly HoraInicio, TimeOnly HoraFin);

[ApiController]
[Route("api/medicos/{id}/horario")]
public sealed class HorariosController : ControllerBase
{
    private readonly ISender _sender;

    public HorariosController(ISender sender) => _sender = sender;

    [Authorize(Roles = "Medico,Administrador")]
    [HttpGet]
    public async Task<ActionResult<List<HorarioDto>>> Listar(int id, CancellationToken ct)
        => Ok(await _sender.Send(new ListarHorarioDeMedicoQuery(id), ct));

    [Authorize(Roles = "Administrador")]
    [HttpPost]
    public async Task<ActionResult<HorarioDto>> Crear(
        int id, HorarioRequest request, CancellationToken ct)
    {
        var command = new CrearHorarioCommand(
            id, request.DiaSemana, request.HoraInicio, request.HoraFin);
        var resultado = await _sender.Send(command, ct);
        return CreatedAtAction(nameof(Listar), new { id }, resultado);
    }

    [Authorize(Roles = "Administrador")]
    [HttpPut("{idHorario}")]
    public async Task<ActionResult<HorarioDto>> Actualizar(
        int id, int idHorario, HorarioRequest request, CancellationToken ct)
    {
        var command = new ActualizarHorarioCommand(
            idHorario, id, request.DiaSemana, request.HoraInicio, request.HoraFin);
        var resultado = await _sender.Send(command, ct);
        return Ok(resultado);
    }

    [Authorize(Roles = "Administrador")]
    [HttpDelete("{idHorario}")]
    public async Task<IActionResult> Eliminar(int id, int idHorario, CancellationToken ct)
    {
        await _sender.Send(new EliminarHorarioCommand(idHorario, id), ct);
        return NoContent();
    }

    [Authorize(Roles = "Paciente")]
    [HttpGet("/api/medicos/{id}/disponibilidad")]
    public async Task<ActionResult<List<BloqueDisponibleDto>>> Disponibilidad(
        int id, [FromQuery] DateOnly fecha, CancellationToken ct)
        => Ok(await _sender.Send(new ObtenerDisponibilidadQuery(id, fecha), ct));
}