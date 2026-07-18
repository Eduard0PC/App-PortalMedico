using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Medicos.Queries.ListarMedicos;

public sealed record ListarMedicosQuery(int? EspecialidadId)
    : IRequest<List<MedicoDto>>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "Medico", "Administrador" };
}