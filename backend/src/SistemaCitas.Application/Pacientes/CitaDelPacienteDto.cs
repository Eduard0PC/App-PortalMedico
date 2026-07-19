namespace SistemaCitas.Application.Pacientes;

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