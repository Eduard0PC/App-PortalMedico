using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

public sealed record ObtenerDisponibilidadQuery(int IdMedico, DateOnly Fecha)
    : IRequest<List<BloqueDisponibleDto>>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente" };
}