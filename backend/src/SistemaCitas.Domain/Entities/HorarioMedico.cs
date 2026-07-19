using SistemaCitas.Domain.Exceptions;

namespace SistemaCitas.Domain.Entities;

public class HorarioMedico
{
    public int Id { get; private set; }
    public int IdMedico { get; private set; }
    public Medico? Medico { get; private set; }
    public int DiaSemana { get; private set; }
    public TimeOnly HoraInicio { get; private set; }
    public TimeOnly HoraFin { get; private set; }

    protected HorarioMedico() { } 

    public HorarioMedico(int idMedico, int diaSemana, TimeOnly horaInicio, TimeOnly horaFin)
    {
        ValidarRango(diaSemana, horaInicio, horaFin);

        IdMedico = idMedico;
        DiaSemana = diaSemana;
        HoraInicio = horaInicio;
        HoraFin = horaFin;
    }

    public void Actualizar(int diaSemana, TimeOnly horaInicio, TimeOnly horaFin)
    {
        ValidarRango(diaSemana, horaInicio, horaFin);

        DiaSemana = diaSemana;
        HoraInicio = horaInicio;
        HoraFin = horaFin;
    }

    private static void ValidarRango(int diaSemana, TimeOnly horaInicio, TimeOnly horaFin)
    {
        if (diaSemana is < 1 or > 5)
            throw new ReglaDeNegocioException("El día de la semana debe estar entre 1 (Lunes) y 5 (Viernes).");

        if (horaFin <= horaInicio)
            throw new ReglaDeNegocioException("La hora de fin debe ser posterior a la hora de inicio.");
    }
}