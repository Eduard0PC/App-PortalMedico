using FluentValidation;

namespace SistemaCitas.Application.Especialidades.Commands.ActualizarEspecialidad;

public sealed class ActualizarEspecialidadCommandValidator
    : AbstractValidator<ActualizarEspecialidadCommand>
{
    public ActualizarEspecialidadCommandValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
        RuleFor(x => x.Nombre).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Descripcion).MaximumLength(255);
    }
}