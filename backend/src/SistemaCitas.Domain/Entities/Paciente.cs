namespace SistemaCitas.Domain.Entities;

public class Paciente
{
    public int Id { get; private set; }
    public string Nombre { get; private set; } = string.Empty;
    public string Apellido { get; private set; } = string.Empty;
    public string Correo { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public string? Telefono { get; private set; }
    public DateOnly? FechaNacimiento { get; private set; }
    public DateTime FechaCreacion { get; private set; }

    protected Paciente() { } 

    public Paciente(
        string nombre,
        string apellido,
        string correo,
        string passwordHash,
        string? telefono,
        DateOnly? fechaNacimiento)
    {
        Nombre = nombre;
        Apellido = apellido;
        Correo = correo;
        PasswordHash = passwordHash;
        Telefono = telefono;
        FechaNacimiento = fechaNacimiento;
        FechaCreacion = DateTime.UtcNow;
    }

    public void ActualizarPerfil(string nombre, string apellido, string? telefono, DateOnly? fechaNacimiento)
    {
        Nombre = nombre;
        Apellido = apellido;
        Telefono = telefono;
        FechaNacimiento = fechaNacimiento;
    }
}