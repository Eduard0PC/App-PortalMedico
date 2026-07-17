using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Infrastructure.Persistence.Repositories;

public sealed class EspecialidadRepository : IEspecialidadRepository
{
    private readonly ApplicationDbContext _context;

    public EspecialidadRepository(ApplicationDbContext context) => _context = context;

    public async Task<Especialidad?> ObtenerPorIdAsync(int id, CancellationToken ct = default) =>
        await _context.Especialidades.FirstOrDefaultAsync(e => e.Id == id, ct);

    public async Task<List<Especialidad>> ListarAsync(CancellationToken ct = default) =>
        await _context.Especialidades.AsNoTracking().ToListAsync(ct);

    public void Agregar(Especialidad especialidad) => _context.Especialidades.Add(especialidad);

    public void Eliminar(Especialidad especialidad) => _context.Especialidades.Remove(especialidad);
}