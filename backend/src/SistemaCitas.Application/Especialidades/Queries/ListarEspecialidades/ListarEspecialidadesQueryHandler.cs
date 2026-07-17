using MediatR;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Especialidades.Queries.ListarEspecialidades;

public sealed class ListarEspecialidadesQueryHandler
    : IRequestHandler<ListarEspecialidadesQuery, List<EspecialidadDto>>
{
    private readonly IEspecialidadRepository _especialidadRepository;

    public ListarEspecialidadesQueryHandler(IEspecialidadRepository especialidadRepository) =>
        _especialidadRepository = especialidadRepository;

    public async Task<List<EspecialidadDto>> Handle(
        ListarEspecialidadesQuery request, CancellationToken ct)
    {
        var especialidades = await _especialidadRepository.ListarAsync(ct);

        return especialidades
            .Select(e => new EspecialidadDto(e.Id, e.Nombre, e.Descripcion))
            .ToList();
    }
}