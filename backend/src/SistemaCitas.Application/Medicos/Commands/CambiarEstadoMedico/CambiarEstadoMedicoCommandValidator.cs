using FluentValidation;

namespace SistemaCitas.Application.Medicos.Commands.CambiarEstadoMedico;

public sealed class CambiarEstadoMedicoCommandValidator : AbstractValidator<CambiarEstadoMedicoCommand>
{
    public CambiarEstadoMedicoCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}