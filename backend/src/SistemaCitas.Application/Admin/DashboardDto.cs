namespace SistemaCitas.Application.Admin;

public sealed record DashboardDto(
    DateOnly Fecha,
    int CitasHoy,
    Dictionary<string, int> CitasPorEstado);