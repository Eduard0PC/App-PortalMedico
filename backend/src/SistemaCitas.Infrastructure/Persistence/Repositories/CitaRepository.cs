using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Enums;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Infrastructure.Persistence.Repositories;

public sealed class CitaRepository : ICitaRepository
{
    private readonly ApplicationDbContext _context;

    public CitaRepository(ApplicationDbContext context) => _context = context;

    public async Task<Cita?> ObtenerPorIdAsync(int id, CancellationToken ct = default) =>
        await _context.Citas
            .Include(c => c.Paciente)
            .Include(c => c.Medico)
            .FirstOrDefaultAsync(c => c.Id == id, ct);

    public async Task<List<Cita>> ListarAsync(
    int? idPaciente,
    int? idMedico,
    DateOnly? fecha,
    EstadoCita? estado,
    CancellationToken ct = default)
    {
        var query = _context.Citas
            .Include(c => c.Medico)
                .ThenInclude(m => m!.Especialidad)
            .AsNoTracking()
            .AsQueryable();

        if (idPaciente is not null)
            query = query.Where(c => c.IdPaciente == idPaciente);

        if (idMedico is not null)
            query = query.Where(c => c.IdMedico == idMedico);

        if (fecha is not null)
            query = query.Where(c => c.Fecha == fecha);

        if (estado is not null)
            query = query.Where(c => c.Estado == estado);

        return await query
            .OrderBy(c => c.Fecha)
            .ThenBy(c => c.HoraInicio)
            .ToListAsync(ct);
    }

    // Usado en Fase 9 para calcular disponibilidad (regla de negocio #1). Solo trae las citas
    // que realmente ocupan un bloque — una cancelada no bloquea el horario.
    public async Task<List<Cita>> ObtenerPorMedicoYFechaAsync(int idMedico, DateOnly fecha, CancellationToken ct = default) =>
        await _context.Citas
            .Where(c => c.IdMedico == idMedico && c.Fecha == fecha && c.Estado != EstadoCita.Cancelada)
            .ToListAsync(ct);

    public async Task<int> ContarPorFechaAsync(DateOnly fecha, CancellationToken ct = default) =>
        await _context.Citas.CountAsync(c => c.Fecha == fecha, ct);

    public async Task<Dictionary<EstadoCita, int>> ContarPorEstadoAsync(CancellationToken ct = default) =>
        await _context.Citas
            .GroupBy(c => c.Estado)
            .Select(g => new { Estado = g.Key, Cantidad = g.Count() })
            .ToDictionaryAsync(x => x.Estado, x => x.Cantidad, ct);

    public void Agregar(Cita cita) => _context.Citas.Add(cita);
}