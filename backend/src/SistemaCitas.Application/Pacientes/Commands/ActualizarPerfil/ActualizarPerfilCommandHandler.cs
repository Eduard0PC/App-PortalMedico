using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Pacientes.Commands.ActualizarPerfil;

public sealed class ActualizarPerfilCommandHandler
    : IRequestHandler<ActualizarPerfilCommand, PacienteDto>
{
    private readonly IPacienteRepository _pacienteRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ActualizarPerfilCommandHandler(
        IPacienteRepository pacienteRepository, IUnitOfWork unitOfWork)
    {
        _pacienteRepository = pacienteRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<PacienteDto> Handle(ActualizarPerfilCommand request, CancellationToken ct)
    {
        var paciente = await _pacienteRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un paciente con id {request.Id}.");

        paciente.ActualizarPerfil(request.Nombre, request.Apellido, request.Telefono, request.FechaNacimiento);
        await _unitOfWork.SaveChangesAsync(ct);

        return new PacienteDto(
            paciente.Id, paciente.Nombre, paciente.Apellido, paciente.Correo,
            paciente.Telefono, paciente.FechaNacimiento, paciente.FechaCreacion);
    }
}