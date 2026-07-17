using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Domain.Interfaces;

public interface IHorarioMedicoRepository
{
    Task<HorarioMedico?> ObtenerPorIdAsync(int id, CancellationToken ct = default);
    Task<List<HorarioMedico>> ObtenerPorMedicoAsync(int idMedico, CancellationToken ct = default);
    Task<List<HorarioMedico>> ObtenerPorMedicoYDiaAsync(int idMedico, int diaSemana, CancellationToken ct = default);
    void Agregar(HorarioMedico horario);
    void Eliminar(HorarioMedico horario);
}