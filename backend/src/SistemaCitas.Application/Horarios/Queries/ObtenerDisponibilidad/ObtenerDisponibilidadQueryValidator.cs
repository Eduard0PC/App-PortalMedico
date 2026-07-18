using FluentValidation;

namespace SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;

public sealed class ObtenerDisponibilidadQueryValidator : AbstractValidator<ObtenerDisponibilidadQuery>
{
    public ObtenerDisponibilidadQueryValidator()
    {
        RuleFor(x => x.IdMedico).GreaterThan(0);
    }
}