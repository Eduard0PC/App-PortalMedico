using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Domain.Interfaces;

public interface IAdministradorRepository
{
    Task<Administrador?> ObtenerPorIdAsync(int id, CancellationToken ct = default);
    Task<Administrador?> ObtenerPorCorreoAsync(string correo, CancellationToken ct = default);
}