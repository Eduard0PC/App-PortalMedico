using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Citas;
using SistemaCitas.Application.Citas.Commands.AtenderCita;
using SistemaCitas.Application.Citas.Commands.CancelarCita;
using SistemaCitas.Application.Citas.Commands.ReagendarCita;
using SistemaCitas.Application.Citas.Commands.ReservarCita;
using SistemaCitas.Application.Citas.Queries.ListarCitas;
using SistemaCitas.Application.Citas.Queries.ObtenerCitaPorId;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.API.Controllers;

/// <summary>Body de POST /api/citas: sin idPaciente — se toma del token.</summary>
public sealed record ReservarCitaRequest(int IdMedico, DateOnly Fecha, TimeOnly HoraInicio, string MotivoConsulta);

/// <summary>Body de PATCH /api/citas/{id}/atender.</summary>
public sealed record AtenderCitaRequest(string NotaMedica, uint RowVersion);

/// <summary>Body de PATCH /api/citas/{id}/cancelar.</summary>
public sealed record CancelarCitaRequest(uint RowVersion);

/// <summary>Body de PATCH /api/citas/{id}/reagendar.</summary>
public sealed record ReagendarCitaRequest(DateOnly Fecha, TimeOnly HoraInicio, uint RowVersion);

[ApiController]
[Route("api/citas")]
public sealed class CitasController : ControllerBase
{
    private readonly ISender _sender;
    private readonly ICurrentUserService _currentUser;

    public CitasController(ISender sender, ICurrentUserService currentUser)
    {
        _sender = sender;
        _currentUser = currentUser;
    }

    [Authorize(Roles = "Paciente")]
    [HttpPost]
    public async Task<ActionResult<CitaDto>> Reservar(ReservarCitaRequest request, CancellationToken ct)
    {
        var command = new ReservarCitaCommand(
            _currentUser.Id, request.IdMedico, request.Fecha, request.HoraInicio, request.MotivoConsulta);
        var resultado = await _sender.Send(command, ct);
        return CreatedAtAction(nameof(ObtenerPorId), new { id = resultado.Id }, resultado);
    }

    [Authorize(Roles = "Paciente,Medico,Administrador")]
    [HttpGet]
    public async Task<ActionResult<List<CitaDto>>> Listar(
        [FromQuery] int? pacienteId,
        [FromQuery] int? medicoId,
        [FromQuery] DateOnly? fecha,
        [FromQuery] string? estado,
        CancellationToken ct)
        => Ok(await _sender.Send(new ListarCitasQuery(pacienteId, medicoId, fecha, estado), ct));

    [Authorize(Roles = "Paciente,Medico,Administrador")]
    [HttpGet("{id}")]
    public async Task<ActionResult<CitaDto>> ObtenerPorId(int id, CancellationToken ct)
        => Ok(await _sender.Send(new ObtenerCitaPorIdQuery(id), ct));

    [Authorize(Roles = "Medico")]
    [HttpPatch("{id}/atender")]
    public async Task<ActionResult<CitaDto>> Atender(int id, AtenderCitaRequest request, CancellationToken ct)
    {
        var command = new AtenderCitaCommand(id, request.NotaMedica, request.RowVersion);
        return Ok(await _sender.Send(command, ct));
    }

    [Authorize(Roles = "Paciente,Administrador")]
    [HttpPatch("{id}/cancelar")]
    public async Task<ActionResult<CitaDto>> Cancelar(int id, CancelarCitaRequest request, CancellationToken ct)
    {
        var command = new CancelarCitaCommand(id, request.RowVersion);
        return Ok(await _sender.Send(command, ct));
    }

    [Authorize(Roles = "Administrador")]
    [HttpPatch("{id}/reagendar")]
    public async Task<ActionResult<CitaDto>> Reagendar(int id, ReagendarCitaRequest request, CancellationToken ct)
    {
        var command = new ReagendarCitaCommand(id, request.Fecha, request.HoraInicio, request.RowVersion);
        return Ok(await _sender.Send(command, ct));
    }
}