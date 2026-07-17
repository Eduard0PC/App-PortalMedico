using FluentValidation;

namespace SistemaCitas.Application.Auth.Commands.LoginPaciente;

public sealed class LoginPacienteCommandValidator : AbstractValidator<LoginPacienteCommand>
{
    public LoginPacienteCommandValidator()
    {
        RuleFor(x => x.Correo).NotEmpty().EmailAddress();
        RuleFor(x => x.Password).NotEmpty();
    }
}