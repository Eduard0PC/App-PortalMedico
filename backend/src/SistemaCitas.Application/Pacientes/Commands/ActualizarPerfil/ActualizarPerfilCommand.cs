using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Pacientes.Commands.ActualizarPerfil;

public sealed record ActualizarPerfilCommand(
    int Id,
    string Nombre,
    string Apellido,
    string? Telefono,
    DateOnly? FechaNacimiento) : IRequest<PacienteDto>, IAuthorizedRequest, IOwnedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente" };
    public int IdPropietario => Id;
    public string RolPropietario => "Paciente";
}