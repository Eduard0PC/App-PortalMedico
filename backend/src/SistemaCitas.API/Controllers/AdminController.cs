using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaCitas.Application.Admin;
using SistemaCitas.Application.Admin.Queries.ObtenerDashboard;

namespace SistemaCitas.API.Controllers;

[ApiController]
[Route("api/admin")]
public sealed class AdminController : ControllerBase
{
    private readonly ISender _sender;

    public AdminController(ISender sender) => _sender = sender;

    [Authorize(Roles = "Administrador")]
    [HttpGet("dashboard")]
    public async Task<ActionResult<DashboardDto>> ObtenerDashboard(CancellationToken ct)
        => Ok(await _sender.Send(new ObtenerDashboardQuery(), ct));
}