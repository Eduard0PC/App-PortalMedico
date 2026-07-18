using FluentValidation;

namespace SistemaCitas.Application.Citas.Queries.ObtenerCitaPorId;

public sealed class ObtenerCitaPorIdQueryValidator : AbstractValidator<ObtenerCitaPorIdQuery>
{
    public ObtenerCitaPorIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}