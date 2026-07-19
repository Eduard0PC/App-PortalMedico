namespace SistemaCitas.Application.Pacientes;

public sealed record PacienteDto(
    int Id,
    string Nombre,
    string Apellido,
    string Correo,
    string? Telefono,
    DateOnly? FechaNacimiento,
    DateTime FechaCreacion);