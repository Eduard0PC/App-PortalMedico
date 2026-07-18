using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Enums;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Citas.Commands.CancelarCita;

public sealed class CancelarCitaCommandHandler : IRequestHandler<CancelarCitaCommand, CitaDto>
{
    private readonly ICitaRepository _citaRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IUnitOfWork _unitOfWork;

    public CancelarCitaCommandHandler(
        ICitaRepository citaRepository, ICurrentUserService currentUser, IUnitOfWork unitOfWork)
    {
        _citaRepository = citaRepository;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
    }

    public async Task<CitaDto> Handle(CancelarCitaCommand request, CancellationToken ct)
    {
        var cita = await _citaRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe una cita con id {request.Id}.");

        if (_currentUser.Rol == "Paciente" && cita.IdPaciente != _currentUser.Id)
            throw new AccesoDenegadoException("No puedes cancelar una cita que no te pertenece.");

        var canceladaPor = _currentUser.Rol == "Paciente" ? CanceladoPor.Paciente : CanceladoPor.Administrador;

        _citaRepository.EstablecerVersionEsperada(cita, request.RowVersion);

        // La regla de +1 día (regla de negocio #2) vive adentro de este método desde la Fase 1 —
        // se aplica sola solo cuando canceladaPor == Paciente; un Administrador nunca queda sujeto
        // a ella (regla de negocio #3).
        cita.Cancelar(canceladaPor, DateTime.UtcNow);

        await _unitOfWork.SaveChangesAsync(ct);

        return CitaDto.DesdeEntidad(cita);
    }
}