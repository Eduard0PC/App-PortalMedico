namespace SistemaCitas.Application.Pacientes;

/// <summary>
/// Vista de una cita para el historial de un paciente (GET /api/pacientes/{id}/citas). Incluye el
/// nombre del médico y de la especialidad ya resueltos (ver el ajuste de Infrastructure en el
/// Paso 7) para que el cliente no tenga que hacer una segunda consulta solo para mostrarlos.
/// </summary>
public sealed record CitaDelPacienteDto(
    int Id,
    DateOnly Fecha,
    TimeOnly HoraInicio,
    TimeOnly HoraFin,
    string MotivoConsulta,
    string Estado,
    string? NotaMedica,
    int IdMedico,
    string NombreMedico,
    string NombreEspecialidad);