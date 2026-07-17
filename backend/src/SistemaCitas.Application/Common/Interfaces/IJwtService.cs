namespace SistemaCitas.Application.Common.Interfaces;

/// <summary>
/// Abstrae la generación del token JWT. Regla de negocio #5: el token incluye el rol
/// (Paciente/Medico/Administrador) y el id correspondiente, que la app Flutter usa para
/// enrutar tras el login y que, más adelante (Fase 12), el AuthorizationBehavior usa para
/// verificar que el recurso pedido pertenece a quien hace la petición.
/// </summary>
public interface IJwtService
{
    string GenerarToken(int id, string correo, string rol);
}