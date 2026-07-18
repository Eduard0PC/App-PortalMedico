namespace SistemaCitas.Application.Admin;

/// <summary>
/// Respuesta de GET /api/admin/dashboard. Fecha indica explícitamente qué día del calendario se
/// usó para calcular CitasHoy (el backend corre en UTC, ver la nota del Paso 4) — así el
/// frontend no tiene que adivinarlo. CitasPorEstado siempre trae las 3 claves
/// ("Programada", "Atendida", "Cancelada"), incluso en 0, para que el cliente no tenga que
/// manejar claves ausentes.
/// </summary>
public sealed record DashboardDto(
    DateOnly Fecha,
    int CitasHoy,
    Dictionary<string, int> CitasPorEstado);