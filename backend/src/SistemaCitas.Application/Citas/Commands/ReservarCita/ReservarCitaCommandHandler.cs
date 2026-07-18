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

        // Paso 1 de la defensa: misma regla de negocio #1 que ObtenerDisponibilidadQuery (Fase 9),
        // pero aplicada a un único bloque candidato en vez de enumerar todos los libres. No es
        // una garantía absoluta por sí sola (ver el comentario debajo) — es la primera línea de
        // defensa, pensada para el caso normal (nadie más reservando al mismo tiempo).
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

        // Paso 2 de la defensa, la que realmente importa contra la condición de carrera: se
        // intenta el Insert igual, sin volver a preguntar. Si otra petición reservó exactamente
        // este mismo bloque en el instante entre el chequeo de arriba y este SaveChangesAsync, el
        // índice único filtrado de la Fase 2 rechaza el INSERT con SqlState 23505, y
        // ApplicationDbContext.SaveChangesAsync (Paso 4 de esta guía) lo traduce a
        // ConflictoDeConcurrenciaException — nunca un error crudo de PostgreSQL.
        var cita = Cita.Reservar(
            request.IdPaciente, request.IdMedico, request.Fecha, request.HoraInicio, horaFin,
            request.MotivoConsulta);

        _citaRepository.Agregar(cita);
        await _unitOfWork.SaveChangesAsync(ct);

        // No se usa CitaDto.DesdeEntidad acá: "cita" se creó en memoria con Cita.Reservar(...),
        // nunca se leyó de la base, así que cita.Paciente/cita.Medico están en null. Se arma el
        // DTO a mano con "paciente" y "medico", que ya están cargados (el segundo con su
        // Especialidad incluida, ver MedicoRepository.ObtenerPorIdAsync de la Fase 2).
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