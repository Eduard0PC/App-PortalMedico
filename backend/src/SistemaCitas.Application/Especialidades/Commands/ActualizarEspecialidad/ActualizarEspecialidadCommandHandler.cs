using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Especialidades.Commands.ActualizarEspecialidad;

public sealed class ActualizarEspecialidadCommandHandler
    : IRequestHandler<ActualizarEspecialidadCommand, EspecialidadDto>
{
    private readonly IEspecialidadRepository _especialidadRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ActualizarEspecialidadCommandHandler(
        IEspecialidadRepository especialidadRepository, IUnitOfWork unitOfWork)
    {
        _especialidadRepository = especialidadRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<EspecialidadDto> Handle(
        ActualizarEspecialidadCommand request, CancellationToken ct)
    {
        var especialidad = await _especialidadRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe una especialidad con id {request.Id}.");

        especialidad.Actualizar(request.Nombre, request.Descripcion);
        await _unitOfWork.SaveChangesAsync(ct);

        return new EspecialidadDto(especialidad.Id, especialidad.Nombre, especialidad.Descripcion);
    }
}