namespace SistemaCitas.Application.Horarios;

/// <summary>
/// Un bloque de 30 minutos disponible para reservar, calculado dinámicamente por
/// ObtenerDisponibilidadQueryHandler. No corresponde a ninguna fila de la base de datos.
/// </summary>
public sealed record BloqueDisponibleDto(TimeOnly HoraInicio, TimeOnly HoraFin);