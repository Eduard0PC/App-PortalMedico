using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Domain.Interfaces;

public interface IMedicoRepository
{
    Task<Medico?> ObtenerPorIdAsync(int id, CancellationToken ct = default);
    Task<Medico?> ObtenerPorCorreoAsync(string correo, CancellationToken ct = default);
    Task<bool> ExisteCorreoAsync(string correo, CancellationToken ct = default);
    Task<List<Medico>> ListarAsync(int? idEspecialidad, CancellationToken ct = default);
    void Agregar(Medico medico);
}