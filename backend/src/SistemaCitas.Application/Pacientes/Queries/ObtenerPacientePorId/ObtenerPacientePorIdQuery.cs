using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Pacientes.Queries.ObtenerPacientePorId;

public sealed record ObtenerPacientePorIdQuery(int Id) : IRequest<PacienteDto>, IAuthorizedRequest, IOwnedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente" };
    public int IdPropietario => Id;
    public string RolPropietario => "Paciente";
}