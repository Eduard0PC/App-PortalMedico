using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;

public sealed record ListarHorarioDeMedicoQuery(int IdMedico)
    : IRequest<List<HorarioDto>>, IAuthorizedRequest, IOwnedRequest
{
    public string[] RolesPermitidos => new[] { "Medico", "Administrador" };
    public int IdPropietario => IdMedico;
    public string RolPropietario => "Medico";
}