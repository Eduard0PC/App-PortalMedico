namespace SistemaCitas.Application.Common.Interfaces;
public interface ICurrentUserService
{
    bool EstaAutenticado { get; }
    int Id { get; }
    string Correo { get; }
    string Rol { get; }
}
