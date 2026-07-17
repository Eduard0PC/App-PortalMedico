namespace SistemaCitas.Domain.Exceptions;

/// <summary>
/// Se lanza cuando una operación viola una regla de negocio esperada
/// (ej. cancelar con menos de 1 día de anticipación).
/// El middleware global de API la traduce a 400 Bad Request.
/// </summary>
public class ReglaDeNegocioException : Exception
{
    public ReglaDeNegocioException(string mensaje) : base(mensaje) { }
}