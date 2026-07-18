using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Especialidades.Commands.EliminarEspecialidad;

public sealed class EliminarEspecialidadCommandHandler : IRequestHandler<EliminarEspecialidadCommand>
{
    private readonly IEspecialidadRepository _especialidadRepository;
    private readonly IMedicoRepository _medicoRepository;
    private readonly IUnitOfWork _unitOfWork;

    public EliminarEspecialidadCommandHandler(
        IEspecialidadRepository especialidadRepository,
        IMedicoRepository medicoRepository,
        IUnitOfWork unitOfWork)
    {
        _especialidadRepository = especialidadRepository;
        _medicoRepository = medicoRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task Handle(EliminarEspecialidadCommand request, CancellationToken ct)
    {
        var especialidad = await _especialidadRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe una especialidad con id {request.Id}.");

        var medicosDeLaEspecialidad = await _medicoRepository.ListarAsync(request.Id, ct);
        if (medicosDeLaEspecialidad.Count > 0)
            throw new ReglaDeNegocioException(
                "No se puede eliminar la especialidad porque tiene médicos asociados.");

        _especialidadRepository.Eliminar(especialidad);
        await _unitOfWork.SaveChangesAsync(ct);
    }
}