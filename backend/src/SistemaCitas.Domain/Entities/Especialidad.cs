namespace SistemaCitas.Domain.Entities;

public class Especialidad
{
    public int Id { get; private set; }
    public string Nombre { get; private set; } = string.Empty;
    public string? Descripcion { get; private set; }

    protected Especialidad() { }

    public Especialidad(string nombre, string? descripcion)
    {
        Nombre = nombre;
        Descripcion = descripcion;
    }

    public void Actualizar(string nombre, string? descripcion)
    {
        Nombre = nombre;
        Descripcion = descripcion;
    }
}