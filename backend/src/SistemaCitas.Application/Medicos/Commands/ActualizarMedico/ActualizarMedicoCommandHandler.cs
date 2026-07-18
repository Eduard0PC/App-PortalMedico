using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Medicos.Commands.ActualizarMedico;

public sealed class ActualizarMedicoCommandHandler
    : IRequestHandler<ActualizarMedicoCommand, MedicoDto>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IEspecialidadRepository _especialidadRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ActualizarMedicoCommandHandler(
        IMedicoRepository medicoRepository,
        IEspecialidadRepository especialidadRepository,
        IUnitOfWork unitOfWork)
    {
        _medicoRepository = medicoRepository;
        _especialidadRepository = especialidadRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<MedicoDto> Handle(ActualizarMedicoCommand request, CancellationToken ct)
    {
        var medico = await _medicoRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.Id}.");

        var especialidad = await _especialidadRepository.ObtenerPorIdAsync(request.IdEspecialidad, ct)
            ?? throw new NotFoundException(
                $"No existe una especialidad con id {request.IdEspecialidad}.");

        medico.ActualizarDatos(request.Nombre, request.Apellido, request.IdEspecialidad, request.Telefono);
        await _unitOfWork.SaveChangesAsync(ct);

        return new MedicoDto(
            medico.Id, medico.Nombre, medico.Apellido, medico.Correo, medico.IdEspecialidad,
            especialidad.Nombre, medico.Telefono, medico.Activo, medico.FechaCreacion);
    }
}