using MediatR;

namespace SistemaCitas.Application.Auth.Commands.LoginAdministrador;

public sealed record LoginAdministradorCommand(string Correo, string Password) : IRequest<AuthResponseDto>;