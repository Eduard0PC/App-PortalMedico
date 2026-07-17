namespace SistemaCitas.Application.Common.Interfaces;

/// <summary>
/// Abstrae el algoritmo de hashing de contraseñas para que Application (y sus Handlers de
/// registro/login, Fase 5) no dependa directamente de BCrypt.Net — esa dependencia concreta
/// vive en Infrastructure. Regla de negocio #4: nunca se guarda ni compara texto plano.
/// </summary>
public interface IPasswordHasher
{
    string Hash(string password);
    bool Verificar(string password, string hash);
}