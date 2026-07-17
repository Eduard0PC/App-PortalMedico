using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Infrastructure.Persistence.Repositories;

public sealed class MedicoRepository : IMedicoRepository
{
    private readonly ApplicationDbContext _context;

    public MedicoRepository(ApplicationDbContext context) => _context = context;

    public async Task<Medico?> ObtenerPorIdAsync(int id, CancellationToken ct = default) =>
        await _context.Medicos
            .Include(m => m.Especialidad)
            .FirstOrDefaultAsync(m => m.Id == id, ct);

    public async Task<Medico?> ObtenerPorCorreoAsync(string correo, CancellationToken ct = default) =>
        await _context.Medicos.FirstOrDefaultAsync(m => m.Correo == correo, ct);

    public async Task<bool> ExisteCorreoAsync(string correo, CancellationToken ct = default) =>
        await _context.Medicos.AnyAsync(m => m.Correo == correo, ct);

    public async Task<List<Medico>> ListarAsync(int? idEspecialidad, CancellationToken ct = default)
    {
        var query = _context.Medicos.Include(m => m.Especialidad).AsNoTracking();

        if (idEspecialidad is not null)
            query = query.Where(m => m.IdEspecialidad == idEspecialidad);

        return await query.ToListAsync(ct);
    }

    public void Agregar(Medico medico) => _context.Medicos.Add(medico);
}