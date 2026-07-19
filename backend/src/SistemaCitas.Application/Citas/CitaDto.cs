using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Application.Citas;
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
{   public static CitaDto DesdeEntidad(Cita cita) => new(
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