using MediatR;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Auth;
using SistemaCitas.Application.Auth.Commands.LoginAdministrador;
using SistemaCitas.Application.Auth.Commands.LoginMedico;
using SistemaCitas.Application.Auth.Commands.LoginPaciente;
using SistemaCitas.Application.Auth.Commands.RegistrarPaciente;

namespace SistemaCitas.API.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController : ControllerBase
{
    private readonly ISender _sender;

    public AuthController(ISender sender) => _sender = sender;

    [HttpPost("pacientes/register")]
    public async Task<ActionResult<AuthResponseDto>> RegistrarPaciente(
        RegistrarPacienteCommand command, CancellationToken ct)
    {
        var resultado = await _sender.Send(command, ct);
        return CreatedAtAction(nameof(RegistrarPaciente), resultado);
    }

    [HttpPost("pacientes/login")]
    public async Task<ActionResult<AuthResponseDto>> LoginPaciente(
        LoginPacienteCommand command, CancellationToken ct)
        => Ok(await _sender.Send(command, ct));

    [HttpPost("medicos/login")]
    public async Task<ActionResult<AuthResponseDto>> LoginMedico(
        LoginMedicoCommand command, CancellationToken ct)
        => Ok(await _sender.Send(command, ct));

    [HttpPost("administradores/login")]
    public async Task<ActionResult<AuthResponseDto>> LoginAdministrador(
        LoginAdministradorCommand command, CancellationToken ct)
        => Ok(await _sender.Send(command, ct));
}