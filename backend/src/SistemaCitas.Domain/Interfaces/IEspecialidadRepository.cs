using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Domain.Interfaces;

public interface IEspecialidadRepository
{
    Task<Especialidad?> ObtenerPorIdAsync(int id, CancellationToken ct = default);
    Task<List<Especialidad>> ListarAsync(CancellationToken ct = default);
    void Agregar(Especialidad especialidad);
    void Eliminar(Especialidad especialidad);
}