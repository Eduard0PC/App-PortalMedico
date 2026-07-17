using MediatR;

namespace SistemaCitas.Application.Auth.Commands.LoginMedico;

public sealed record LoginMedicoCommand(string Correo, string Password) : IRequest<AuthResponseDto>;