using FluentValidation;

namespace SistemaCitas.Application.Citas.Commands.CancelarCita;

public sealed class CancelarCitaCommandValidator : AbstractValidator<CancelarCitaCommand>
{
    public CancelarCitaCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}