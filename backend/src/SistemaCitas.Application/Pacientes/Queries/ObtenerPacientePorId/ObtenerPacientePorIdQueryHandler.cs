using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Pacientes.Queries.ObtenerPacientePorId;

public sealed class ObtenerPacientePorIdQueryHandler
    : IRequestHandler<ObtenerPacientePorIdQuery, PacienteDto>
{
    private readonly IPacienteRepository _pacienteRepository;

    public ObtenerPacientePorIdQueryHandler(IPacienteRepository pacienteRepository) =>
        _pacienteRepository = pacienteRepository;

    public async Task<PacienteDto> Handle(ObtenerPacientePorIdQuery request, CancellationToken ct)
    {
        var paciente = await _pacienteRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un paciente con id {request.Id}.");

        return new PacienteDto(
            paciente.Id, paciente.Nombre, paciente.Apellido, paciente.Correo,
            paciente.Telefono, paciente.FechaNacimiento, paciente.FechaCreacion);
    }
}