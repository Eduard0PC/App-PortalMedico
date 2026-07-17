using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Infrastructure.Persistence.Repositories;

public sealed class PacienteRepository : IPacienteRepository
{
    private readonly ApplicationDbContext _context;

    public PacienteRepository(ApplicationDbContext context) => _context = context;

    public async Task<Paciente?> ObtenerPorIdAsync(int id, CancellationToken ct = default) =>
        await _context.Pacientes.FirstOrDefaultAsync(p => p.Id == id, ct);

    public async Task<Paciente?> ObtenerPorCorreoAsync(string correo, CancellationToken ct = default) =>
        await _context.Pacientes.FirstOrDefaultAsync(p => p.Correo == correo, ct);

    public async Task<bool> ExisteCorreoAsync(string correo, CancellationToken ct = default) =>
        await _context.Pacientes.AnyAsync(p => p.Correo == correo, ct);

    public async Task<List<Paciente>> BuscarPorNombreAsync(string? nombre, CancellationToken ct = default)
    {
        var query = _context.Pacientes.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(nombre))
        {
            query = query.Where(p =>
                EF.Functions.ILike(p.Nombre, $"%{nombre}%") ||
                EF.Functions.ILike(p.Apellido, $"%{nombre}%"));
        }

        return await query.ToListAsync(ct);
    }

    public void Agregar(Paciente paciente) => _context.Pacientes.Add(paciente);
}