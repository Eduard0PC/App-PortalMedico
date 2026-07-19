using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Enums;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Citas.Queries.ListarCitas;

public sealed class ListarCitasQueryHandler : IRequestHandler<ListarCitasQuery, List<CitaDto>>
{
    private readonly ICitaRepository _citaRepository;
    private readonly ICurrentUserService _currentUser;

    public ListarCitasQueryHandler(ICitaRepository citaRepository, ICurrentUserService currentUser)
    {
        _citaRepository = citaRepository;
        _currentUser = currentUser;
    }

    public async Task<List<CitaDto>> Handle(ListarCitasQuery request, CancellationToken ct)
    {
        var idPacienteFiltro = request.PacienteId;
        var idMedicoFiltro = request.MedicoId;

        if (_currentUser.Rol == "Paciente")
            idPacienteFiltro = _currentUser.Id;
        else if (_currentUser.Rol == "Medico")
            idMedicoFiltro = _currentUser.Id;

        EstadoCita? estadoFiltro = request.Estado is not null
            ? Enum.Parse<EstadoCita>(request.Estado, ignoreCase: true)
            : null;

        var citas = await _citaRepository.ListarAsync(
            idPacienteFiltro, idMedicoFiltro, request.Fecha, estadoFiltro, ct);

        return citas.Select(CitaDto.DesdeEntidad).ToList();
    }
}