using FluentValidation;

namespace SistemaCitas.Application.Medicos.Queries.ObtenerMedicoPorId;

public sealed class ObtenerMedicoPorIdQueryValidator : AbstractValidator<ObtenerMedicoPorIdQuery>
{
    public ObtenerMedicoPorIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}