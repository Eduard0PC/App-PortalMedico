using FluentValidation;

namespace SistemaCitas.Application.Horarios.Commands.ActualizarHorario;

public sealed class ActualizarHorarioCommandValidator : AbstractValidator<ActualizarHorarioCommand>
{
    public ActualizarHorarioCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
        RuleFor(x => x.IdMedico).GreaterThan(0);

        RuleFor(x => x.DiaSemana)
            .InclusiveBetween(1, 5)
            .WithMessage("El día de la semana debe estar entre 1 (Lunes) y 5 (Viernes).");

        RuleFor(x => x.HoraFin)
            .GreaterThan(x => x.HoraInicio)
            .WithMessage("La hora de fin debe ser posterior a la hora de inicio.");
    }
}