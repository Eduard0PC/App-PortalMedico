namespace SistemaCitas.Application.Common.Interfaces;

public interface IJwtService
{
    string GenerarToken(int id, string correo, string rol);
}