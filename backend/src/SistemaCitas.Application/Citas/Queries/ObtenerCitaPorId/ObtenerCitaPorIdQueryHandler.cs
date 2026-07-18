using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Citas.Queries.ObtenerCitaPorId;

public sealed class ObtenerCitaPorIdQueryHandler : IRequestHandler<ObtenerCitaPorIdQuery, CitaDto>
{
    private readonly ICitaRepository _citaRepository;
    private readonly ICurrentUserService _currentUser;

    public ObtenerCitaPorIdQueryHandler(ICitaRepository citaRepository, ICurrentUserService currentUser)
    {
        _citaRepository = citaRepository;
        _currentUser = currentUser;
    }

    public async Task<CitaDto> Handle(ObtenerCitaPorIdQuery request, CancellationToken ct)
    {
        var cita = await _citaRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe una cita con id {request.Id}.");

        if (_currentUser.Rol == "Paciente" && cita.IdPaciente != _currentUser.Id)
            throw new AccesoDenegadoException("No puedes acceder a una cita que no te pertenece.");

        if (_currentUser.Rol == "Medico" && cita.IdMedico != _currentUser.Id)
            throw new AccesoDenegadoException("No puedes acceder a una cita que no es tuya.");

        // Administrador: sin restricción adicional, ya pasó el chequeo de rol de AuthorizationBehavior.

        return CitaDto.DesdeEntidad(cita);
    }
}