using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Medicos.Commands.ActualizarMedico;

public sealed record ActualizarMedicoCommand(
    int Id,
    string Nombre,
    string Apellido,
    int IdEspecialidad,
    string? Telefono) : IRequest<MedicoDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}