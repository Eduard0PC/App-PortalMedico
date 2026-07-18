using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Citas.Queries.ListarCitas;

public sealed record ListarCitasQuery(int? PacienteId, int? MedicoId, DateOnly? Fecha, string? Estado)
    : IRequest<List<CitaDto>>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "Medico", "Administrador" };
}