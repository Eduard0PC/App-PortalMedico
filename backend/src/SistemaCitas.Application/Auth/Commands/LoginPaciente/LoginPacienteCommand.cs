using MediatR;

namespace SistemaCitas.Application.Auth.Commands.LoginPaciente;

public sealed record LoginPacienteCommand(string Correo, string Password) : IRequest<AuthResponseDto>;