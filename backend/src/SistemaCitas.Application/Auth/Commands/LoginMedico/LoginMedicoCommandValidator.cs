using FluentValidation;

namespace SistemaCitas.Application.Auth.Commands.LoginMedico;

public sealed class LoginMedicoCommandValidator : AbstractValidator<LoginMedicoCommand>
{
    public LoginMedicoCommandValidator()
    {
        RuleFor(x => x.Correo).NotEmpty().EmailAddress();
        RuleFor(x => x.Password).NotEmpty();
    }
}