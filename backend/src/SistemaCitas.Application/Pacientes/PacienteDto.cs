namespace SistemaCitas.Application.Pacientes;

/// <summary>
/// Forma de salida común a los endpoints de perfil (GET, PUT y la búsqueda) de /api/pacientes.
/// Nunca incluye PasswordHash — ese dato no sale nunca de Domain/Infrastructure.
/// </summary>
public sealed record PacienteDto(
    int Id,
    string Nombre,
    string Apellido,
    string Correo,
    string? Telefono,
    DateOnly? FechaNacimiento,
    DateTime FechaCreacion);