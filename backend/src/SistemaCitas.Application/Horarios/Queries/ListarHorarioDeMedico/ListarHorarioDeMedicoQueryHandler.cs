using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;

public sealed class ListarHorarioDeMedicoQueryHandler
    : IRequestHandler<ListarHorarioDeMedicoQuery, List<HorarioDto>>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;

    public ListarHorarioDeMedicoQueryHandler(
        IMedicoRepository medicoRepository, IHorarioMedicoRepository horarioRepository)
    {
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
    }

    public async Task<List<HorarioDto>> Handle(
        ListarHorarioDeMedicoQuery request, CancellationToken ct)
    {
        _ = await _medicoRepository.ObtenerPorIdAsync(request.IdMedico, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.IdMedico}.");

        var horarios = await _horarioRepository.ObtenerPorMedicoAsync(request.IdMedico, ct);

        return horarios
            .Select(h => new HorarioDto(h.Id, h.IdMedico, h.DiaSemana, h.HoraInicio, h.HoraFin))
            .OrderBy(h => h.DiaSemana)
            .ThenBy(h => h.HoraInicio)
            .ToList();
    }
}