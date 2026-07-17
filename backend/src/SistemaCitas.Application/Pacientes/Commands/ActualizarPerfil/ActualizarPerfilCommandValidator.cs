using FluentValidation;

namespace SistemaCitas.Application.Pacientes.Commands.ActualizarPerfil;

public sealed class ActualizarPerfilCommandValidator : AbstractValidator<ActualizarPerfilCommand>
{
    public ActualizarPerfilCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
        RuleFor(x => x.Nombre).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Apellido).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Telefono).MaximumLength(20);

        RuleFor(x => x.FechaNacimiento)
            .LessThan(DateOnly.FromDateTime(DateTime.UtcNow))
            .When(x => x.FechaNacimiento is not null)
            .WithMessage("La fecha de nacimiento no puede ser futura.");
    }
}