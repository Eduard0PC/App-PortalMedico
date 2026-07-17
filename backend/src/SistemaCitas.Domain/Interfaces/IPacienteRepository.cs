using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Domain.Interfaces;

public interface IPacienteRepository
{
    Task<Paciente?> ObtenerPorIdAsync(int id, CancellationToken ct = default);
    Task<Paciente?> ObtenerPorCorreoAsync(string correo, CancellationToken ct = default);
    Task<bool> ExisteCorreoAsync(string correo, CancellationToken ct = default);
    Task<List<Paciente>> BuscarPorNombreAsync(string? nombre, CancellationToken ct = default);
    void Agregar(Paciente paciente);
}