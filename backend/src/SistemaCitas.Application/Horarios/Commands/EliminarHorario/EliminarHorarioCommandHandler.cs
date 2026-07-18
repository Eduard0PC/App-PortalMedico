using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Horarios.Commands.EliminarHorario;

public sealed class EliminarHorarioCommandHandler : IRequestHandler<EliminarHorarioCommand>
{
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly IUnitOfWork _unitOfWork;

    public EliminarHorarioCommandHandler(
        IHorarioMedicoRepository horarioRepository, IUnitOfWork unitOfWork)
    {
        _horarioRepository = horarioRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task Handle(EliminarHorarioCommand request, CancellationToken ct)
    {
        var horario = await _horarioRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un bloque de horario con id {request.Id}.");

        if (horario.IdMedico != request.IdMedico)
            throw new NotFoundException(
                $"El bloque de horario {request.Id} no pertenece al médico con id {request.IdMedico}.");

        _horarioRepository.Eliminar(horario);
        await _unitOfWork.SaveChangesAsync(ct);
    }
}