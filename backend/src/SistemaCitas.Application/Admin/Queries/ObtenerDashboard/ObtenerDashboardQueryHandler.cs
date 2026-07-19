using MediatR;
using SistemaCitas.Application.Admin;
using SistemaCitas.Domain.Enums;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Admin.Queries.ObtenerDashboard;

public sealed class ObtenerDashboardQueryHandler
    : IRequestHandler<ObtenerDashboardQuery, DashboardDto>
{
    private readonly ICitaRepository _citaRepository;

    public ObtenerDashboardQueryHandler(ICitaRepository citaRepository) =>
        _citaRepository = citaRepository;

    public async Task<DashboardDto> Handle(ObtenerDashboardQuery request, CancellationToken ct)
    {
        var hoy = DateOnly.FromDateTime(DateTime.UtcNow);

        var citasHoy = await _citaRepository.ContarPorFechaAsync(hoy, ct);
        var conteoPorEstado = await _citaRepository.ContarPorEstadoAsync(ct);

        var citasPorEstado = Enum.GetValues<EstadoCita>()
            .ToDictionary(estado => estado.ToString(), estado => conteoPorEstado.GetValueOrDefault(estado));

        return new DashboardDto(hoy, citasHoy, citasPorEstado);
    }
}