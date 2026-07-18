using FluentValidation;

namespace SistemaCitas.Application.Citas.Commands.ReagendarCita;

public sealed class ReagendarCitaCommandValidator : AbstractValidator<ReagendarCitaCommand>
{
    public ReagendarCitaCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
        RuleFor(x => x.Fecha).NotEqual(default(DateOnly));
        RuleFor(x => x.HoraInicio).NotEqual(default(TimeOnly));
    }
}