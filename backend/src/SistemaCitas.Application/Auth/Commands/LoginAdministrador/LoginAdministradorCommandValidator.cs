using FluentValidation;

namespace SistemaCitas.Application.Auth.Commands.LoginAdministrador;

public sealed class LoginAdministradorCommandValidator : AbstractValidator<LoginAdministradorCommand>
{
    public LoginAdministradorCommandValidator()
    {
        RuleFor(x => x.Correo).NotEmpty().EmailAddress();
        RuleFor(x => x.Password).NotEmpty();
    }
}