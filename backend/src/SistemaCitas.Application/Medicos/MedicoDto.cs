namespace SistemaCitas.Application.Medicos;

public sealed record MedicoDto(
    int Id,
    string Nombre,
    string Apellido,
    string Correo,
    int IdEspecialidad,
    string NombreEspecialidad,
    string? Telefono,
    bool Activo,
    DateTime FechaCreacion);