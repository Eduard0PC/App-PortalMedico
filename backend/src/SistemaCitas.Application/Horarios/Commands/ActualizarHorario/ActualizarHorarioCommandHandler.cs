using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Horarios.Commands.ActualizarHorario;

public sealed class ActualizarHorarioCommandHandler
    : IRequestHandler<ActualizarHorarioCommand, HorarioDto>
{
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ActualizarHorarioCommandHandler(
        IHorarioMedicoRepository horarioRepository, IUnitOfWork unitOfWork)
    {
        _horarioRepository = horarioRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<HorarioDto> Handle(ActualizarHorarioCommand request, CancellationToken ct)
    {
        var horario = await _horarioRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un bloque de horario con id {request.Id}.");

        if (horario.IdMedico != request.IdMedico)
            throw new NotFoundException(
                $"El bloque de horario {request.Id} no pertenece al médico con id {request.IdMedico}.");

        var otrosDelDia = (await _horarioRepository.ObtenerPorMedicoYDiaAsync(
                request.IdMedico, request.DiaSemana, ct))
            .Where(h => h.Id != request.Id);

        if (otrosDelDia.Any(h =>
                HorarioSuperposicion.Existe(h.HoraInicio, h.HoraFin, request.HoraInicio, request.HoraFin)))
            throw new ReglaDeNegocioException(
                "Ya existe otro bloque de horario para ese médico que se superpone con el rango indicado.");

        horario.Actualizar(request.DiaSemana, request.HoraInicio, request.HoraFin);
        await _unitOfWork.SaveChangesAsync(ct);

        return new HorarioDto(
            horario.Id, horario.IdMedico, horario.DiaSemana, horario.HoraInicio, horario.HoraFin);
    }
}