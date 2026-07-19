using MediatR;
using SistemaCitas.Domain.Entities;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;
using SistemaCitas.Domain.Primitives;

namespace SistemaCitas.Application.Citas.Commands.ReservarCita;

public sealed class ReservarCitaCommandHandler : IRequestHandler<ReservarCitaCommand, CitaDto>
{
    private static readonly TimeSpan DuracionBloque = TimeSpan.FromMinutes(30);

    private readonly IPacienteRepository _pacienteRepository;
    private readonly IMedicoRepository _medicoRepository;
    private readonly IHorarioMedicoRepository _horarioRepository;
    private readonly ICitaRepository _citaRepository;
    private readonly IUnitOfWork _unitOfWork;

    public ReservarCitaCommandHandler(
        IPacienteRepository pacienteRepository,
        IMedicoRepository medicoRepository,
        IHorarioMedicoRepository horarioRepository,
        ICitaRepository citaRepository,
        IUnitOfWork unitOfWork)
    {
        _pacienteRepository = pacienteRepository;
        _medicoRepository = medicoRepository;
        _horarioRepository = horarioRepository;
        _citaRepository = citaRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<CitaDto> Handle(ReservarCitaCommand request, CancellationToken ct)
    {
        var paciente = await _pacienteRepository.ObtenerPorIdAsync(request.IdPaciente, ct)
            ?? throw new NotFoundException($"No existe un paciente con id {request.IdPaciente}.");

        var medico = await _medicoRepository.ObtenerPorIdAsync(request.IdMedico, ct)
            ?? throw new NotFoundException($"No existe un médico con id {request.IdMedico}.");

        var horaFin = request.HoraInicio.Add(DuracionBloque);

        var diaSemana = (int)request.Fecha.DayOfWeek;
        if (diaSemana is < 1 or > 5)
            throw new ReglaDeNegocioException("El médico no atiende sábados ni domingos.");

        var horariosDelDia = await _horarioRepository.ObtenerPorMedicoYDiaAsync(
            request.IdMedico, diaSemana, ct);

        var horarioQueContiene = horariosDelDia.FirstOrDefault(h =>
            request.HoraInicio >= h.HoraInicio && horaFin <= h.HoraFin);

        if (horarioQueContiene is null)
            throw new ReglaDeNegocioException(
                "El horario solicitado está fuera del horario de atención del médico ese día.");

        var minutosDesdeInicioDeBloque = (request.HoraInicio - horarioQueContiene.HoraInicio).TotalMinutes;
        if (minutosDesdeInicioDeBloque % DuracionBloque.TotalMinutes != 0)
            throw new ReglaDeNegocioException(
                "El horario solicitado no coincide con un bloque válido de 30 minutos. Usá uno de " +
                "los bloques devueltos por GET /api/medicos/{id}/disponibilidad.");

        var citasDelDia = await _citaRepository.ObtenerPorMedicoYFechaAsync(request.IdMedico, request.Fecha, ct);

        var yaOcupado = citasDelDia.Any(c => request.HoraInicio < c.HoraFin && c.HoraInicio < horaFin);
        if (yaOcupado)
            throw new ReglaDeNegocioException("El horario solicitado ya no está disponible.");

        var cita = Cita.Reservar(
            request.IdPaciente, request.IdMedico, request.Fecha, request.HoraInicio, horaFin,
            request.MotivoConsulta);

        _citaRepository.Agregar(cita);
        await _unitOfWork.SaveChangesAsync(ct);

        return new CitaDto(
            cita.Id,
            cita.IdPaciente,
            $"{paciente.Nombre} {paciente.Apellido}",
            cita.IdMedico,
            $"{medico.Nombre} {medico.Apellido}",
            medico.Especialidad?.Nombre ?? string.Empty,
            cita.Fecha,
            cita.HoraInicio,
            cita.HoraFin,
            cita.MotivoConsulta,
            cita.Estado.ToString(),
            cita.NotaMedica,
            cita.CanceladaPor?.ToString(),
            cita.FechaCreacion,
            cita.FechaActualizacion,
            cita.RowVersion);
    }
}