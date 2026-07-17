namespace SistemaCitas.Application.Common.Interfaces;

/// <summary>
/// Abstrae el acceso al usuario autenticado de la petición actual (id, correo y rol, leídos
/// de los claims del JWT). Application y sus behaviors (AuthorizationBehavior) lo consumen sin
/// depender de HttpContext — esa dependencia concreta vive en la implementación de API (Paso 10).
/// </summary>
public interface ICurrentUserService
{
    bool EstaAutenticado { get; }
    int Id { get; }
    string Correo { get; }

    /// <summary>Uno de "Paciente", "Medico" o "Administrador" (mismo valor que el claim de rol
    /// emitido por IJwtService en la Fase 3).</summary>
    string Rol { get; }
}
