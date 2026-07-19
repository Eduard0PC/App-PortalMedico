using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

public sealed class ObtenerDisponibilidadQueryHandler
    : IRequestHandler<ObtenerDisponibilidadQuery, List<BloqueDisponibleDto>>
{
    private static readonly TimeSpan DuracionBloque = TimeSpan.FromMinutes(30);

    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly ICitaRepository _citaRepository;

    public ObtenerDisponibilidadQueryHandler(
        IMedicoRepository medicoRepository,
        IHorarioMedicoRepository horarioRepository,
        ICitaRepository citaRepository)
    {
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
        _citaRepository = citaRepository;
    }

    public async Task<List<BloqueDisponibleDto>> Handle(
        ObtenerDisponibilidadQuery request, CancellationToken ct)
    {
        _ = await _medicoRepository.ObtenerPorIdAsync(request.IdMedico, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.IdMedico}.");

        var diaSemana = (int)request.Fecha.DayOfWeek;

        if (diaSemana is < 1 or > 5)
            return new List<BloqueDisponibleDto>();

        var horariosDelDia = await _horarioRepository.ObtenerPorMedicoYDiaAsync(
            request.IdMedico, diaSemana, ct);

        if (horariosDelDia.Count == 0)
            return new List<BloqueDisponibleDto>();

        var citasDelDia = await _citaRepository.ObtenerPorMedicoYFechaAsync(
            request.IdMedico, request.Fecha, ct);

        var disponibles = new List<BloqueDisponibleDto>();

        foreach (var horario in horariosDelDia)
        {
            var inicioBloque = horario.HoraInicio;

            while (inicioBloque.Add(DuracionBloque) <= horario.HoraFin)
            {
                var finBloque = inicioBloque.Add(DuracionBloque);

                var ocupado = citasDelDia.Any(c =>
                    inicioBloque < c.HoraFin && c.HoraInicio < finBloque);

                if (!ocupado)
                    disponibles.Add(new BloqueDisponibleDto(inicioBloque, finBloque));

                inicioBloque = finBloque;
            }
        }

        return disponibles.OrderBy(b => b.HoraInicio).ToList();
    }
}