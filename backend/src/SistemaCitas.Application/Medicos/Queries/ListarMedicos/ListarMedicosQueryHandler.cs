using MediatR;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Medicos.Queries.ListarMedicos;

public sealed class ListarMedicosQueryHandler : IRequestHandler<ListarMedicosQuery, List<MedicoDto>>
{
    private readonly IMedicoRepository _medicoRepository;

    public ListarMedicosQueryHandler(IMedicoRepository medicoRepository) =>
        _medicoRepository = medicoRepository;

    public async Task<List<MedicoDto>> Handle(ListarMedicosQuery request, CancellationToken ct)
    {
        var medicos = await _medicoRepository.ListarAsync(request.EspecialidadId, ct);

        return medicos
            .Select(m => new MedicoDto(
                m.Id, m.Nombre, m.Apellido, m.Correo, m.IdEspecialidad,
                m.Especialidad?.Nombre ?? string.Empty, m.Telefono, m.Activo, m.FechaCreacion))
            .ToList();
    }
}