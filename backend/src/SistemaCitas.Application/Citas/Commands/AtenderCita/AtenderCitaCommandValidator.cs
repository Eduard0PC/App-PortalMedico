using FluentValidation;

namespace SistemaCitas.Application.Citas.Commands.AtenderCita;

public sealed class AtenderCitaCommandValidator : AbstractValidator<AtenderCitaCommand>
{
    public AtenderCitaCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
        RuleFor(x => x.NotaMedica).NotEmpty();
    }
}