using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Horarios.Commands.CrearHorario;

public sealed class CrearHorarioCommandHandler : IRequestHandler<CrearHorarioCommand, HorarioDto>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly IUnitOfWork _unitOfWork;

    public CrearHorarioCommandHandler(
        IMedicoRepository medicoRepository,
        IHorarioMedicoRepository horarioRepository,
        IUnitOfWork unitOfWork)
    {
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<HorarioDto> Handle(CrearHorarioCommand request, CancellationToken ct)
    {
        _ = await _medicoRepository.ObtenerPorIdAsync(request.IdMedico, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.IdMedico}.");

        var horariosDelDia = await _horarioRepository.ObtenerPorMedicoYDiaAsync(
            request.IdMedico, request.DiaSemana, ct);

        if (horariosDelDia.Any(h =>
                HorarioSuperposicion.Existe(h.HoraInicio, h.HoraFin, request.HoraInicio, request.HoraFin)))
            throw new ReglaDeNegocioException(
                "Ya existe un bloque de horario para ese médico y día que se superpone con el rango indicado.");

        var horario = new HorarioMedico(
            request.IdMedico, request.DiaSemana, request.HoraInicio, request.HoraFin);

        _horarioRepository.Agregar(horario);
        await _unitOfWork.SaveChangesAsync(ct);

        return new HorarioDto(
            horario.Id, horario.IdMedico, horario.DiaSemana, horario.HoraInicio, horario.HoraFin);
    }
}