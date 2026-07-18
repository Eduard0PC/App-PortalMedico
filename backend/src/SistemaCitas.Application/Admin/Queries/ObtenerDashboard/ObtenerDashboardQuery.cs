using MediatR;
using SistemaCitas.Application.Admin;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Admin.Queries.ObtenerDashboard;

public sealed record ObtenerDashboardQuery : IRequest<DashboardDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}