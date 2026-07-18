using FluentValidation;

namespace SistemaCitas.Application.Citas.Commands.ReservarCita;

public sealed class ReservarCitaCommandValidator : AbstractValidator<ReservarCitaCommand>
{
    public ReservarCitaCommandValidator()
    {
        RuleFor(x => x.IdPaciente).GreaterThan(0);
        RuleFor(x => x.IdMedico).GreaterThan(0);
        RuleFor(x => x.Fecha).NotEqual(default(DateOnly));
        RuleFor(x => x.HoraInicio).NotEqual(default(TimeOnly));

        RuleFor(x => x.MotivoConsulta)
            .NotEmpty()
            .MaximumLength(255);
    }
}