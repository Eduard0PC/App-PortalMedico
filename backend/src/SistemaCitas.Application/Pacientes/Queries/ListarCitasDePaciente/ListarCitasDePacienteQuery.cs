using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Pacientes.Queries.ListarCitasDePaciente;

public sealed record ListarCitasDePacienteQuery(int Id)
    : IRequest<List<CitaDelPacienteDto>>, IAuthorizedRequest, IOwnedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "Medico", "Administrador" };
    public int IdPropietario => Id;
    public string RolPropietario => "Paciente";
}