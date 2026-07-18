using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Medicos.Commands.CambiarEstadoMedico;

public sealed class CambiarEstadoMedicoCommandHandler
    : IRequestHandler<CambiarEstadoMedicoCommand, MedicoDto>
{
    private readonly IMedicoRepository _medicoRepository;
    private readonly IUnitOfWork _unitOfWork;

    public CambiarEstadoMedicoCommandHandler(
        IMedicoRepository medicoRepository, IUnitOfWork unitOfWork)
    {
        _medicoRepository = medicoRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<MedicoDto> Handle(CambiarEstadoMedicoCommand request, CancellationToken ct)
    {
        var medico = await _medicoRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.Id}.");

        if (request.Activo)
            medico.Activar();
        else
            medico.Desactivar();

        await _unitOfWork.SaveChangesAsync(ct);

        return new MedicoDto(
            medico.Id, medico.Nombre, medico.Apellido, medico.Correo, medico.IdEspecialidad,
            medico.Especialidad?.Nombre ?? string.Empty, medico.Telefono, medico.Activo,
            medico.FechaCreacion);
    }
}