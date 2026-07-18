namespace SistemaCitas.Application.Horarios;

/// <summary>
/// Forma de salida común a los 4 endpoints de /api/medicos/{id}/horario.
/// </summary>
public sealed record HorarioDto(
    int Id,
    int IdMedico,
    int DiaSemana,
    TimeOnly HoraInicio,
    TimeOnly HoraFin);