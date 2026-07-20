using FluentValidation;

namespace SistemaCitas.Application.Horarios.Queries.BuscarMedicosDisponibles;

public sealed class BuscarMedicosDisponiblesQueryValidator
    : AbstractValidator<BuscarMedicosDisponiblesQuery>
{
    public BuscarMedicosDisponiblesQueryValidator()
    {
        RuleFor(x => x.IdEspecialidad).GreaterThan(0).When(x => x.IdEspecialidad is not null);
    }
}