using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Pacientes.Queries.BuscarPacientes;

public sealed record BuscarPacientesQuery(string? Nombre) : IRequest<List<PacienteDto>>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Medico", "Administrador" };
}