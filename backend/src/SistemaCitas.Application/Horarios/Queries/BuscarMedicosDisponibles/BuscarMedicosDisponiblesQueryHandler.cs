using MediatR;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.BuscarMedicosDisponibles;

public sealed class BuscarMedicosDisponiblesQueryHandler
    : IRequestHandler<BuscarMedicosDisponiblesQuery, List<MedicoDisponibleDto>>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly ICitaRepository _citaRepository;

    public BuscarMedicosDisponiblesQueryHandler(
        IMedicoRepository medicoRepository,
        IHorarioMedicoRepository horarioRepository,
        ICitaRepository citaRepository)
    {
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
        _citaRepository = citaRepository;
    }

    public async Task<List<MedicoDisponibleDto>> Handle(
        BuscarMedicosDisponiblesQuery request, CancellationToken ct)
    {
        var diaSemana = (int)request.Fecha.DayOfWeek;
        if (diaSemana is < 1 or > 5)
            return new List<MedicoDisponibleDto>();

        var medicos = await _medicoRepository.ListarAsync(request.IdEspecialidad, ct);
        var resultado = new List<MedicoDisponibleDto>();

        foreach (var medico in medicos.Where(m => m.Activo))
        {
            var horariosDelDia = await _horarioRepository.ObtenerPorMedicoYDiaAsync(
                medico.Id, diaSemana, ct);

            if (horariosDelDia.Count == 0)
                continue;

            var citasDelDia = await _citaRepository.ObtenerPorMedicoYFechaAsync(
                medico.Id, request.Fecha, ct);

            var bloques = CalculadorDisponibilidad.CalcularBloques(horariosDelDia, citasDelDia);

            var bloqueQueContiene = bloques.FirstOrDefault(b =>
                request.Hora >= b.HoraInicio && request.Hora < b.HoraFin);

            if (bloqueQueContiene is not null)
            {
                resultado.Add(new MedicoDisponibleDto(
                    medico.Id,
                    $"{medico.Nombre} {medico.Apellido}",
                    medico.Especialidad?.Nombre ?? string.Empty,
                    bloqueQueContiene.HoraInicio,
                    bloqueQueContiene.HoraFin));
            }
        }

        return resultado.OrderBy(m => m.NombreCompleto).ToList();
    }
}