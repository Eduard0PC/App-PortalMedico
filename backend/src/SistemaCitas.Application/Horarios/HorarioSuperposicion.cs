namespace SistemaCitas.Application.Horarios;

/// <summary>
/// Determina si dos bloques de horario (del mismo médico y día) se solapan en el tiempo. Dos
/// bloques adyacentes (ej. HoraFin de uno == HoraInicio del otro) NO se consideran superpuestos.
/// Usado por CrearHorarioCommandHandler y ActualizarHorarioCommandHandler porque, a diferencia de
/// la doble reserva de Citas (Fase 2), no existe ninguna restricción a nivel de base de datos que
/// lo impida para HorarioMedico.
/// </summary>
public static class HorarioSuperposicion
{
    public static bool Existe(TimeOnly aInicio, TimeOnly aFin, TimeOnly bInicio, TimeOnly bFin) =>
        aInicio < bFin && bInicio < aFin;
}