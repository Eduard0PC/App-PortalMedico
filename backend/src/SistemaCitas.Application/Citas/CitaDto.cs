using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Application.Citas;

/// <summary>
/// Forma de salida común a los 6 endpoints de /api/citas. Incluye RowVersion — el cliente debe
/// reenviarlo tal cual en cualquier PATCH posterior (atender/cancelar/reagendar) para que el
/// backend detecte si alguien más modificó la cita mientras tanto (ver Paso 2 y 4 de esta guía).
/// </summary>
public sealed record CitaDto(
    int Id,
    int IdPaciente,
    string NombrePaciente,
    int IdMedico,
    string NombreMedico,
    string NombreEspecialidad,
    DateOnly Fecha,
    TimeOnly HoraInicio,
    TimeOnly HoraFin,
    string MotivoConsulta,
    string Estado,
    string? NotaMedica,
    string? CanceladaPor,
    DateTime FechaCreacion,
    DateTime FechaActualizacion,
    uint RowVersion)
{
    /// <summary>
    /// Único punto de mapeo Cita -> CitaDto del módulo. Asume que cita.Paciente y
    /// cita.Medico.Especialidad ya vienen cargados (Include/ThenInclude, ver Paso 3) — si alguno
    /// no viene incluido, el nombre correspondiente queda como cadena vacía en vez de tirar una
    /// excepción de referencia nula.
    /// </summary>
    public static CitaDto DesdeEntidad(Cita cita) => new(
        cita.Id,
        cita.IdPaciente,
        cita.Paciente is not null ? $"{cita.Paciente.Nombre} {cita.Paciente.Apellido}" : string.Empty,
        cita.IdMedico,
        cita.Medico is not null ? $"{cita.Medico.Nombre} {cita.Medico.Apellido}" : string.Empty,
        cita.Medico?.Especialidad?.Nombre ?? string.Empty,
        cita.Fecha,
        cita.HoraInicio,
        cita.HoraFin,
        cita.MotivoConsulta,
        cita.Estado.ToString(),
        cita.NotaMedica,
        cita.CanceladaPor?.ToString(),
        cita.FechaCreacion,
        cita.FechaActualizacion,
        cita.RowVersion);
}