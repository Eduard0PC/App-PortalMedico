using MediatR;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Citas.Commands.AtenderCita;

public sealed class AtenderCitaCommandHandler : IRequestHandler<AtenderCitaCommand, CitaDto>
{
    private readonly ICitaRepository _citaRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IUnitOfWork _unitOfWork;

    public AtenderCitaCommandHandler(
        ICitaRepository citaRepository, ICurrentUserService currentUser, IUnitOfWork unitOfWork)
    {
        _citaRepository = citaRepository;
        _currentUser = currentUser;
        _unitOfWork = unitOfWork;
    }

    public async Task<CitaDto> Handle(AtenderCitaCommand request, CancellationToken ct)
    {
        var cita = await _citaRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe una cita con id {request.Id}.");

        if (cita.IdMedico != _currentUser.Id)
            throw new AccesoDenegadoException("No puedes atender una cita que no es tuya.");

        _citaRepository.EstablecerVersionEsperada(cita, request.RowVersion);

        cita.MarcarComoAtendida(request.NotaMedica);

        await _unitOfWork.SaveChangesAsync(ct);

        return CitaDto.DesdeEntidad(cita);
    }
}