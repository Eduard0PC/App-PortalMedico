using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Medicos.Queries.ObtenerMedicoPorId;

public sealed class ObtenerMedicoPorIdQueryHandler
    : IRequestHandler<ObtenerMedicoPorIdQuery, MedicoDto>
{
    private readonly IMedicoRepository _medicoRepository;

    public ObtenerMedicoPorIdQueryHandler(IMedicoRepository medicoRepository) =>
        _medicoRepository = medicoRepository;

    public async Task<MedicoDto> Handle(ObtenerMedicoPorIdQuery request, CancellationToken ct)
    {
        var medico = await _medicoRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.Id}.");

        return new MedicoDto(
            medico.Id, medico.Nombre, medico.Apellido, medico.Correo, medico.IdEspecialidad,
            medico.Especialidad?.Nombre ?? string.Empty, medico.Telefono, medico.Activo,
            medico.FechaCreacion);
    }
}