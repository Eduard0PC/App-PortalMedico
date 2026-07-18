using MediatR;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Pacientes.Queries.BuscarPacientes;

public sealed class BuscarPacientesQueryHandler
    : IRequestHandler<BuscarPacientesQuery, List<PacienteDto>>
{
    private readonly IPacienteRepository _pacienteRepository;

    public BuscarPacientesQueryHandler(IPacienteRepository pacienteRepository) =>
        _pacienteRepository = pacienteRepository;

    public async Task<List<PacienteDto>> Handle(BuscarPacientesQuery request, CancellationToken ct)
    {
        var pacientes = await _pacienteRepository.BuscarPorNombreAsync(request.Nombre, ct);

        return pacientes
            .Select(p => new PacienteDto(
                p.Id, p.Nombre, p.Apellido, p.Correo, p.Telefono, p.FechaNacimiento, p.FechaCreacion))
            .ToList();
    }
}