using FluentValidation;

namespace SistemaCitas.Application.Auth.Commands.RegistrarPaciente;

public sealed class RegistrarPacienteCommandValidator : AbstractValidator<RegistrarPacienteCommand>
{
    public RegistrarPacienteCommandValidator()
    {
        RuleFor(x => x.Nombre).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Apellido).NotEmpty().MaximumLength(100);

        RuleFor(x => x.Correo)
            .NotEmpty()
            .EmailAddress().WithMessage("El correo no tiene un formato válido.")
            .MaximumLength(150);

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(6).WithMessage("La contraseña debe tener al menos 6 caracteres.");

        RuleFor(x => x.Telefono).MaximumLength(12).MinimumLength(7).WithMessage("El teléfono debe tener entre 7 y 12 caracteres.");

        RuleFor(x => x.FechaNacimiento)
            .LessThan(DateOnly.FromDateTime(DateTime.UtcNow))
            .When(x => x.FechaNacimiento is not null)
            .WithMessage("La fecha de nacimiento no puede ser futura.");
    }
}