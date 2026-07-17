using Microsoft.EntityFrameworkCore;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Infrastructure.Persistence.Repositories;

public sealed class HorarioMedicoRepository : IHorarioMedicoRepository
{
    private readonly ApplicationDbContext _context;

    public HorarioMedicoRepository(ApplicationDbContext context) => _context = context;

    public async Task<HorarioMedico?> ObtenerPorIdAsync(int id, CancellationToken ct = default) =>
        await _context.HorariosMedico.FirstOrDefaultAsync(h => h.Id == id, ct);

    public async Task<List<HorarioMedico>> ObtenerPorMedicoAsync(int idMedico, CancellationToken ct = default) =>
        await _context.HorariosMedico
            .Where(h => h.IdMedico == idMedico)
            .OrderBy(h => h.DiaSemana)
            .ThenBy(h => h.HoraInicio)
            .ToListAsync(ct);

    public async Task<List<HorarioMedico>> ObtenerPorMedicoYDiaAsync(int idMedico, int diaSemana, CancellationToken ct = default) =>
        await _context.HorariosMedico
            .Where(h => h.IdMedico == idMedico && h.DiaSemana == diaSemana)
            .ToListAsync(ct);

    public void Agregar(HorarioMedico horario) => _context.HorariosMedico.Add(horario);

    public void Eliminar(HorarioMedico horario) => _context.HorariosMedico.Remove(horario);
}