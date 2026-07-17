namespace SistemaCitas.Application.Common.Interfaces;

/// <summary>
/// Un Command/Query que requiere un usuario autenticado con uno de los roles listados.
/// Los endpoints públicos (login, registro de paciente) NO implementan esta interfaz.
/// </summary>
public interface IAuthorizedRequest
{
    /// <summary>Roles permitidos para ejecutar este Command/Query, ej. new[] { "Medico" } o
    /// new[] { "Paciente", "Administrador" }.</summary>
    string[] RolesPermitidos { get; }
}