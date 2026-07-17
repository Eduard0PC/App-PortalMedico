namespace SistemaCitas.Domain.Exceptions;

/// <summary>
/// Se lanza cuando se busca una entidad por id y no existe.
/// El middleware global de API la traduce a 404 Not Found.
/// </summary>
public class NotFoundException : Exception
{
    public NotFoundException(string mensaje) : base(mensaje) { }
}