namespace SistemaCitas.Domain.Exceptions;

/// <summary>
/// Se lanza cuando el correo no existe o la contraseña no coincide, en cualquiera de los 3
/// logins (Paciente, Medico, Administrador). El mensaje es siempre genérico a propósito — no
/// distingue "correo no existe" de "contraseña incorrecta", para no darle a un atacante pistas
/// de qué correos están registrados. El middleware global de API (Fase 12) la traduce a
/// 401 Unauthorized.
/// </summary>
public class CredencialesInvalidasException : Exception
{
    public CredencialesInvalidasException(string mensaje) : base(mensaje) { }
}