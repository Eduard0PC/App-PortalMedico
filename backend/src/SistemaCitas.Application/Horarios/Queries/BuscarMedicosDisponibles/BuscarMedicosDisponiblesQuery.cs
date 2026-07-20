using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.BuscarMedicosDisponibles;

public sealed record BuscarMedicosDisponiblesQuery(int? IdEspecialidad, DateOnly Fecha, TimeOnly Hora)
    : IRequest<List<MedicoDisponibleDto>>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente" };
}