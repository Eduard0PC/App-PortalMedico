using FluentValidation;

namespace SistemaCitas.Application.Especialidades.Commands.CrearEspecialidad;

public sealed class CrearEspecialidadCommandValidator : AbstractValidator<CrearEspecialidadCommand>
{
    public CrearEspecialidadCommandValidator()
    {
        RuleFor(x => x.Nombre).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Descripcion).MaximumLength(255);
    }
}