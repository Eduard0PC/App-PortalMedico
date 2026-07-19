using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Medicos;
using SistemaCitas.Application.Medicos.Commands.ActualizarMedico;
using SistemaCitas.Application.Medicos.Commands.CambiarEstadoMedico;
using SistemaCitas.Application.Medicos.Commands.CrearMedico;
using SistemaCitas.Application.Medicos.Queries.ListarMedicos;
using SistemaCitas.Application.Medicos.Queries.ObtenerMedicoPorId;

namespace SistemaCitas.API.Controllers;

/// <summary>Body de PUT /api/medicos/{id}: solo los campos editables, sin Id (ese viene de la
/// ruta), sin Correo ni Password (no editables desde este endpoint).</summary>
public sealed record ActualizarMedicoRequest(
    string Nombre, string Apellido, int IdEspecialidad, string? Telefono);

/// <summary>Body de PATCH /api/medicos/{id}/estado: un único campo, la nueva baja/alta lógica.</summary>
public sealed record CambiarEstadoMedicoRequest(bool Activo);

[ApiController]
[Route("api/medicos")]
public sealed class MedicosController : ControllerBase
{
    private readonly ISender _sender;

    public MedicosController(ISender sender) => _sender = sender;

    [Authorize(Roles = "Paciente,Medico,Administrador")]
    [HttpGet]
    public async Task<ActionResult<List<MedicoDto>>> Listar(
        [FromQuery] int? especialidadId, CancellationToken ct)
        => Ok(await _sender.Send(new ListarMedicosQuery(especialidadId), ct));

    [Authorize(Roles = "Paciente,Medico,Administrador")]
    [HttpGet("{id}")]
    public async Task<ActionResult<MedicoDto>> ObtenerPorId(int id, CancellationToken ct)
        => Ok(await _sender.Send(new ObtenerMedicoPorIdQuery(id), ct));

    [Authorize(Roles = "Administrador")]
    [HttpPost]
    public async Task<ActionResult<MedicoDto>> Crear(CrearMedicoCommand command, CancellationToken ct)
    {
        var resultado = await _sender.Send(command, ct);
        return CreatedAtAction(nameof(ObtenerPorId), new { id = resultado.Id }, resultado);
    }

    [Authorize(Roles = "Administrador")]
    [HttpPut("{id}")]
    public async Task<ActionResult<MedicoDto>> Actualizar(
        int id, ActualizarMedicoRequest request, CancellationToken ct)
    {
        var command = new ActualizarMedicoCommand(
            id, request.Nombre, request.Apellido, request.IdEspecialidad, request.Telefono);
        var resultado = await _sender.Send(command, ct);
        return Ok(resultado);
    }

    [Authorize(Roles = "Administrador")]
    [HttpPatch("{id}/estado")]
    public async Task<ActionResult<MedicoDto>> CambiarEstado(
        int id, CambiarEstadoMedicoRequest request, CancellationToken ct)
    {
        var command = new CambiarEstadoMedicoCommand(id, request.Activo);
        var resultado = await _sender.Send(command, ct);
        return Ok(resultado);
    }
}