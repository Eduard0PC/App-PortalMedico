using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Pacientes;
using SistemaCitas.Application.Pacientes.Commands.ActualizarPerfil;
using SistemaCitas.Application.Pacientes.Queries.BuscarPacientes;
using SistemaCitas.Application.Pacientes.Queries.ListarCitasDePaciente;
using SistemaCitas.Application.Pacientes.Queries.ObtenerPacientePorId;

namespace SistemaCitas.API.Controllers;

/// <summary>Body de PUT /api/pacientes/{id}: solo los campos editables del perfil, sin Id
/// (ese viene de la ruta) ni Correo (no es editable).</summary>
public sealed record ActualizarPerfilRequest(
    string Nombre, string Apellido, string? Telefono, DateOnly? FechaNacimiento);

[ApiController]
[Route("api/pacientes")]
public sealed class PacientesController : ControllerBase
{
    private readonly ISender _sender;

    public PacientesController(ISender sender) => _sender = sender;

    [Authorize(Roles = "Paciente")]
    [HttpGet("{id}")]
    public async Task<ActionResult<PacienteDto>> ObtenerPorId(int id, CancellationToken ct)
        => Ok(await _sender.Send(new ObtenerPacientePorIdQuery(id), ct));

    [Authorize(Roles = "Paciente")]
    [HttpPut("{id}")]
    public async Task<ActionResult<PacienteDto>> ActualizarPerfil(
        int id, ActualizarPerfilRequest request, CancellationToken ct)
    {
        var command = new ActualizarPerfilCommand(
            id, request.Nombre, request.Apellido, request.Telefono, request.FechaNacimiento);
        var resultado = await _sender.Send(command, ct);
        return Ok(resultado);
    }

    [Authorize(Roles = "Medico,Administrador")]
    [HttpGet]
    public async Task<ActionResult<List<PacienteDto>>> Buscar(
        [FromQuery] string? nombre, CancellationToken ct)
        => Ok(await _sender.Send(new BuscarPacientesQuery(nombre), ct));

    [Authorize(Roles = "Paciente,Medico,Administrador")]
    [HttpGet("{id}/citas")]
    public async Task<ActionResult<List<CitaDelPacienteDto>>> ListarCitas(int id, CancellationToken ct)
        => Ok(await _sender.Send(new ListarCitasDePacienteQuery(id), ct));
}