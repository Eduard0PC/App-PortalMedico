using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Medicos.Queries.ObtenerMedicoPorId;

public sealed record ObtenerMedicoPorIdQuery(int Id) : IRequest<MedicoDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "Medico", "Administrador" };
}