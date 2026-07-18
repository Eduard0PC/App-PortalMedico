using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Citas.Commands.ReagendarCita;

public sealed class ReagendarCitaCommandHandler : IRequestHandler<ReagendarCitaCommand, CitaDto>
{
    private static readonly TimeSpan DuracionBloque = TimeSpan.FromMinutes(30);

    private readonly ICitaRepository _citaRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ReagendarCitaCommandHandler(
        ICitaRepository citaRepository, IHorarioMedicoRepository horarioRepository, IUnitOfWork unitOfWork)
    {
        _citaRepository = citaRepository;
        _horarioRepository = horarioRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<CitaDto> Handle(ReagendarCitaCommand request, CancellationToken ct)
    {
        var cita = await _citaRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe una cita con id {request.Id}.");

        var horaFin = request.HoraInicio.Add(DuracionBloque);

        var diaSemana = (int)request.Fecha.DayOfWeek;
        if (diaSemana is < 1 or > 5)
            throw new ReglaDeNegocioException("El médico no atiende sábados ni domingos.");

        var horariosDelDia = await _horarioRepository.ObtenerPorMedicoYDiaAsync(cita.IdMedico, diaSemana, ct);

        var horarioQueContiene = horariosDelDia.FirstOrDefault(h =>
            request.HoraInicio >= h.HoraInicio && horaFin <= h.HoraFin);

        if (horarioQueContiene is null)
            throw new ReglaDeNegocioException(
                "El nuevo horario está fuera del horario de atención del médico ese día.");

        var minutosDesdeInicioDeBloque = (request.HoraInicio - horarioQueContiene.HoraInicio).TotalMinutes;
        if (minutosDesdeInicioDeBloque % DuracionBloque.TotalMinutes != 0)
            throw new ReglaDeNegocioException(
                "El nuevo horario no coincide con un bloque válido de 30 minutos.");

        // Excluye la propia cita (request.Id) de la comparación — si no, reagendar dentro del
        // mismo día "chocaría" siempre contra su propio bloque anterior.
        var citasDelDia = (await _citaRepository.ObtenerPorMedicoYFechaAsync(cita.IdMedico, request.Fecha, ct))
            .Where(c => c.Id != cita.Id);

        var yaOcupado = citasDelDia.Any(c => request.HoraInicio < c.HoraFin && c.HoraInicio < horaFin);
        if (yaOcupado)
            throw new ReglaDeNegocioException("El nuevo horario ya no está disponible.");

        _citaRepository.EstablecerVersionEsperada(cita, request.RowVersion);

        cita.Reagendar(request.Fecha, request.HoraInicio, horaFin);

        await _unitOfWork.SaveChangesAsync(ct);

        return CitaDto.DesdeEntidad(cita);
    }
}