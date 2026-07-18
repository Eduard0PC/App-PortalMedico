using MediatR;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Especialidades.Commands.CrearEspecialidad;

public sealed class CrearEspecialidadCommandHandler
    : IRequestHandler<CrearEspecialidadCommand, EspecialidadDto>
{
    private readonly IEspecialidadRepository _especialidadRepository;
    private readonly IUnitOfWork _unitOfWork;

    public CrearEspecialidadCommandHandler(
        IEspecialidadRepository especialidadRepository, IUnitOfWork unitOfWork)
    {
        _especialidadRepository = especialidadRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<EspecialidadDto> Handle(CrearEspecialidadCommand request, CancellationToken ct)
    {
        var especialidad = new Especialidad(request.Nombre, request.Descripcion);

        _especialidadRepository.Agregar(especialidad);
        await _unitOfWork.SaveChangesAsync(ct);

        return new EspecialidadDto(especialidad.Id, especialidad.Nombre, especialidad.Descripcion);
    }
}