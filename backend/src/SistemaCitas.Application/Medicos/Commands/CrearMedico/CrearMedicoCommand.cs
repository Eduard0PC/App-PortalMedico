using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Medicos.Commands.CrearMedico;

public sealed record CrearMedicoCommand(
    string Nombre,
    string Apellido,
    string Correo,
    string Password,
    int IdEspecialidad,
    string? Telefono) : IRequest<MedicoDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}