namespace SistemaCitas.Application.Horarios;

public static class HorarioSuperposicion
{
    public static bool Existe(TimeOnly aInicio, TimeOnly aFin, TimeOnly bInicio, TimeOnly bFin) =>
        aInicio < bFin && bInicio < aFin;
}