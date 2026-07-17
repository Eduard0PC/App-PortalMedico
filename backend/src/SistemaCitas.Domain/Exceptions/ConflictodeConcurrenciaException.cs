namespace SistemaCitas.Domain.Exceptions;

/// <summary>
/// Se lanza cuando dos operaciones chocan sobre la misma cita
/// (RowVersion desactualizado) o sobre el mismo bloque de horario.
/// El middleware global de API la traduce a 409 Conflict.
/// </summary>
public class ConflictoDeConcurrenciaException : Exception
{
    public ConflictoDeConcurrenciaException(string mensaje) : base(mensaje) { }
}