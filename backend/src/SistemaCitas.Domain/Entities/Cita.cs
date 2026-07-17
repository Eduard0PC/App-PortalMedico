using SistemaCitas.Domain.Enums;
using SistemaCitas.Domain.Exceptions;

namespace SistemaCitas.Domain.Entities;

public class Cita
{
    public int Id { get; private set; }
    public int IdPaciente { get; private set; }
    public Paciente? Paciente { get; private set; }
    public int IdMedico { get; private set; }
    public Medico? Medico { get; private set; }
    public DateOnly Fecha { get; private set; }
    public TimeOnly HoraInicio { get; private set; }
    public TimeOnly HoraFin { get; private set; }
    public string MotivoConsulta { get; private set; } = string.Empty;
    public EstadoCita Estado { get; private set; }
    public string? NotaMedica { get; private set; }
    public CanceladoPor? CanceladaPor { get; private set; }
    public DateTime FechaCreacion { get; private set; }
    public DateTime FechaActualizacion { get; private set; }

    public uint RowVersion { get; private set; } 

    protected Cita() { }

    private Cita(int idPaciente, int idMedico, DateOnly fecha, TimeOnly horaInicio, TimeOnly horaFin, string motivoConsulta)
    {
        IdPaciente = idPaciente;
        IdMedico = idMedico;
        Fecha = fecha;
        HoraInicio = horaInicio;
        HoraFin = horaFin;
        MotivoConsulta = motivoConsulta;
        Estado = EstadoCita.Programada;
        FechaCreacion = DateTime.UtcNow;
        FechaActualizacion = DateTime.UtcNow;
    }

    /// <summary>
    /// Crea una cita nueva en estado Programada. La validación de disponibilidad del bloque
    /// (regla de negocio #1) se hace antes de llegar acá, en el Handler de Application
    /// (Fase 10), porque necesita consultar el repositorio — no es responsabilidad de la entidad.
    /// </summary>
    public static Cita Reservar(
        int idPaciente,
        int idMedico,
        DateOnly fecha,
        TimeOnly horaInicio,
        TimeOnly horaFin,
        string motivoConsulta)
    {
        if (string.IsNullOrWhiteSpace(motivoConsulta))
            throw new ReglaDeNegocioException("El motivo de la consulta es obligatorio.");

        if (horaFin <= horaInicio)
            throw new ReglaDeNegocioException("La hora de fin debe ser posterior a la hora de inicio.");

        return new Cita(idPaciente, idMedico, fecha, horaInicio, horaFin, motivoConsulta);
    }

    /// <summary>
    /// Regla de negocio #2 y #3: un paciente solo puede cancelar con más de 1 día de
    /// anticipación; un administrador puede cancelar sin esa restricción.
    /// </summary>
    public void Cancelar(CanceladoPor canceladaPor, DateTime ahora)
    {
        if (Estado == EstadoCita.Cancelada)
            throw new ReglaDeNegocioException("La cita ya se encuentra cancelada.");

        if (Estado == EstadoCita.Atendida)
            throw new ReglaDeNegocioException("No se puede cancelar una cita que ya fue atendida.");

        if (canceladaPor == CanceladoPor.Paciente)
        {
            var inicioCita = Fecha.ToDateTime(HoraInicio);
            if (inicioCita - ahora <= TimeSpan.FromDays(1))
                throw new ReglaDeNegocioException(
                    "Solo puedes cancelar con más de 1 día de anticipación. Comunícate directamente con la clínica.");
        }

        Estado = EstadoCita.Cancelada;
        CanceladaPor = canceladaPor;
        FechaActualizacion = DateTime.UtcNow;
    }

    public void MarcarComoAtendida(string notaMedica)
    {
        if (Estado != EstadoCita.Programada)
            throw new ReglaDeNegocioException("Solo se puede marcar como atendida una cita que está programada.");

        if (string.IsNullOrWhiteSpace(notaMedica))
            throw new ReglaDeNegocioException("La nota médica es obligatoria al marcar la cita como atendida.");

        Estado = EstadoCita.Atendida;
        NotaMedica = notaMedica;
        FechaActualizacion = DateTime.UtcNow;
    }
}