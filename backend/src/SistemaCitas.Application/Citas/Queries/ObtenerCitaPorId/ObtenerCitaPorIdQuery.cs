using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Citas.Queries.ObtenerCitaPorId;

public sealed record ObtenerCitaPorIdQuery(int Id) : IRequest<CitaDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "Medico", "Administrador" };
}