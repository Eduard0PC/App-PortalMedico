using FluentValidation;

namespace SistemaCitas.Application.Medicos.Commands.ActualizarMedico;

public sealed class ActualizarMedicoCommandValidator : AbstractValidator<ActualizarMedicoCommand>
{
    public ActualizarMedicoCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
        RuleFor(x => x.Nombre).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Apellido).NotEmpty().MaximumLength(100);
        RuleFor(x => x.IdEspecialidad).GreaterThan(0);
        RuleFor(x => x.Telefono).MaximumLength(20);
    }
}