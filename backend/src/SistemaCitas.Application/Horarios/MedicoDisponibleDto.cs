namespace SistemaCitas.Application.Horarios;

public sealed record MedicoDisponibleDto(
    int IdMedico,
    string NombreCompleto,
    string NombreEspecialidad,
    TimeOnly HoraInicio,
    TimeOnly HoraFin);