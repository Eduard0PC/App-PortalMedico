using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Especialidades.Queries.ListarEspecialidades;

public sealed record ListarEspecialidadesQuery : IRequest<List<EspecialidadDto>>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "Administrador" };
}