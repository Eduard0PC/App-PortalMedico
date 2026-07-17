namespace SistemaCitas.Application.Auth;

/// <summary>
/// Respuesta común a los 4 endpoints de /api/auth. NombreCompleto y Rol le evitan a la app
/// Flutter tener que decodificar el JWT solo para saber a qué pantalla navegar tras el login.
/// </summary>
public sealed record AuthResponseDto(
    string Token,
    int Id,
    string NombreCompleto,
    string Correo,
    string Rol);