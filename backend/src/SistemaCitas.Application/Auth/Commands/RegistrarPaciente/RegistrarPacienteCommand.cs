using SistemaCitas.Application.Auth;
using MediatR;

namespace SistemaCitas.Application.Auth.Commands.RegistrarPaciente;

public sealed record RegistrarPacienteCommand(
    string Nombre,
    string Apellido,
    string Correo,
    string Password,
    string? Telefono,
    DateOnly? FechaNacimiento) : IRequest<AuthResponseDto>;