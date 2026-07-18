using FluentValidation;

namespace SistemaCitas.Application.Medicos.Commands.CrearMedico;

public sealed class CrearMedicoCommandValidator : AbstractValidator<CrearMedicoCommand>
{
    public CrearMedicoCommandValidator()
    {
        RuleFor(x => x.Nombre).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Apellido).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Correo).NotEmpty().EmailAddress().MaximumLength(150);

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(6).WithMessage("La contraseña debe tener al menos 6 caracteres.");

        RuleFor(x => x.IdEspecialidad).GreaterThan(0);
        RuleFor(x => x.Telefono).MaximumLength(20);
    }
}