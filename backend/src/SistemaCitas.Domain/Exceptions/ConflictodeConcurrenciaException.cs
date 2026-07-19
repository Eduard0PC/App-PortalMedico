namespace SistemaCitas.Domain.Exceptions;

public class ConflictoDeConcurrenciaException : Exception
{
    public ConflictoDeConcurrenciaException(string mensaje) : base(mensaje) { }
}