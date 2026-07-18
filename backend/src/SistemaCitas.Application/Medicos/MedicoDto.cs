namespace SistemaCitas.Application.Medicos;

/// <summary>
/// Forma de salida común a los 5 endpoints de /api/medicos. Nunca incluye PasswordHash — ese dato
/// no sale nunca de Domain/Infrastructure. NombreEspecialidad viaja ya resuelto para que el
/// cliente no necesite una segunda consulta solo para mostrarlo.
/// </summary>
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