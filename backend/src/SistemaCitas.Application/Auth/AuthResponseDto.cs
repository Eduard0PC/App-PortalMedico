namespace SistemaCitas.Application.Auth;

public sealed record AuthResponseDto(
    string Token,
    int Id,
    string NombreCompleto,
    string Correo,
    string Rol);