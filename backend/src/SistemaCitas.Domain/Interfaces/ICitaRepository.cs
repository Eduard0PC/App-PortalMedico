using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Enums;

namespace SistemaCitas.Domain.Interfaces;

public interface ICitaRepository
{
    Task<Cita?> ObtenerPorIdAsync(int id, CancellationToken ct = default);

    Task<List<Cita>> ListarAsync(
        int? idPaciente,
        int? idMedico,
        DateOnly? fecha,
        EstadoCita? estado,
        CancellationToken ct = default);

    // Usado en Fase 9 para calcular disponibilidad (regla de negocio #1):
    // trae las citas no canceladas de un médico en un día puntual.
    Task<List<Cita>> ObtenerPorMedicoYFechaAsync(int idMedico, DateOnly fecha, CancellationToken ct = default);

    // Usados en Fase 11 para el dashboard de administrador.
    Task<int> ContarPorFechaAsync(DateOnly fecha, CancellationToken ct = default);
    Task<Dictionary<EstadoCita, int>> ContarPorEstadoAsync(CancellationToken ct = default);

    void Agregar(Cita cita);

    void EstablecerVersionEsperada(Cita cita, uint rowVersionEsperado);


}