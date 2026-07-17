namespace SistemaCitas.Domain.Entities;

public class Medico
{
    public int Id { get; private set; }
    public string Nombre { get; private set; } = string.Empty;
    public string Apellido { get; private set; } = string.Empty;
    public string Correo { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public int IdEspecialidad { get; private set; }
    public Especialidad? Especialidad { get; private set; }
    public string? Telefono { get; private set; }
    public bool Activo { get; private set; }
    public DateTime FechaCreacion { get; private set; }

    protected Medico() { } 

    public Medico(
        string nombre,
        string apellido,
        string correo,
        string passwordHash,
        int idEspecialidad,
        string? telefono)
    {
        Nombre = nombre;
        Apellido = apellido;
        Correo = correo;
        PasswordHash = passwordHash;
        IdEspecialidad = idEspecialidad;
        Telefono = telefono;
        Activo = true;
        FechaCreacion = DateTime.UtcNow;
    }

    public void ActualizarDatos(string nombre, string apellido, int idEspecialidad, string? telefono)
    {
        Nombre = nombre;
        Apellido = apellido;
        IdEspecialidad = idEspecialidad;
        Telefono = telefono;
    }

    public void Activar() => Activo = true;

    public void Desactivar() => Activo = false;
}