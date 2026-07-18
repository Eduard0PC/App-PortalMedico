using FluentValidation;

namespace SistemaCitas.Application.Horarios.Commands.CrearHorario;

public sealed class CrearHorarioCommandValidator : AbstractValidator<CrearHorarioCommand>
{
    public CrearHorarioCommandValidator()
    {
        RuleFor(x => x.IdMedico).GreaterThan(0);

        RuleFor(x => x.DiaSemana)
            .InclusiveBetween(1, 5)
            .WithMessage("El día de la semana debe estar entre 1 (Lunes) y 5 (Viernes).");

        RuleFor(x => x.HoraFin)
            .GreaterThan(x => x.HoraInicio)
            .WithMessage("La hora de fin debe ser posterior a la hora de inicio.");
    }
}