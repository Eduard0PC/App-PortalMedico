using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Infrastructure.Persistence.Repositories;

public sealed class AdministradorRepository : IAdministradorRepository
{
    private readonly ApplicationDbContext _context;

    public AdministradorRepository(ApplicationDbContext context) => _context = context;

    public async Task<Administrador?> ObtenerPorIdAsync(int id, CancellationToken ct = default) =>
        await _context.Administradores.FirstOrDefaultAsync(a => a.Id == id, ct);

    public async Task<Administrador?> ObtenerPorCorreoAsync(string correo, CancellationToken ct = default) =>
        await _context.Administradores.FirstOrDefaultAsync(a => a.Correo == correo, ct);
}