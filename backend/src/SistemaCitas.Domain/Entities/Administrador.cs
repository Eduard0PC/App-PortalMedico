namespace SistemaCitas.Domain.Entities;

public class Administrador
{
    public int Id { get; private set; }
    public string Nombre { get; private set; } = string.Empty;
    public string Correo { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public DateTime FechaCreacion { get; private set; }

    protected Administrador() { } 

    public Administrador(string nombre, string correo, string passwordHash)
    {
        Nombre = nombre;
        Correo = correo;
        PasswordHash = passwordHash;
        FechaCreacion = DateTime.UtcNow;
    }
}