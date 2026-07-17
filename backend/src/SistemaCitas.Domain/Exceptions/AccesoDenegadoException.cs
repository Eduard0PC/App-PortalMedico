namespace SistemaCitas.Domain.Exceptions;

/// <summary>
/// Se lanza cuando un usuario autenticado no tiene permiso para la operación solicitada:
/// su rol no está entre los permitidos, o el recurso que pide no le pertenece
/// (ej. un paciente intentando ver la historia de otro paciente).
/// El middleware global de API la traduce a 403 Forbidden.
/// </summary>
public class AccesoDenegadoException : Exception
{
    public AccesoDenegadoException(string mensaje) : base(mensaje) { }
}