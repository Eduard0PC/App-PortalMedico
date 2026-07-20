using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

public sealed class ObtenerDisponibilidadQueryHandler
    : IRequestHandler<ObtenerDisponibilidadQuery, List<BloqueDisponibleDto>>
{
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

        return CalculadorDisponibilidad.CalcularBloques(horariosDelDia, citasDelDia);
    }
}