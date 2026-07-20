using SistemaCitas.Domain.Entities;

namespace SistemaCitas.Application.Horarios;

public static class CalculadorDisponibilidad
{
    private static readonly TimeSpan DuracionBloque = TimeSpan.FromMinutes(30);

    public static List<BloqueDisponibleDto> CalcularBloques(
        List<HorarioMedico> horariosDelDia, List<Cita> citasDelDia)
    {
        var disponibles = new List<BloqueDisponibleDto>();

        foreach (var horario in horariosDelDia)
        {
            var inicioBloque = horario.HoraInicio;

            while (inicioBloque.Add(DuracionBloque) <= horario.HoraFin)
            {
                var finBloque = inicioBloque.Add(DuracionBloque);

                var ocupado = citasDelDia.Any(c =>
                    inicioBloque < c.HoraFin && c.HoraInicio < finBloque);

                if (!ocupado)
                    disponibles.Add(new BloqueDisponibleDto(inicioBloque, finBloque));

                inicioBloque = finBloque;
            }
        }

        return disponibles.OrderBy(b => b.HoraInicio).ToList();
    }
}