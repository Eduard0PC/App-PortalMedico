using FluentValidation;

namespace SistemaCitas.Application.Pacientes.Queries.ObtenerPacientePorId;

public sealed class ObtenerPacientePorIdQueryValidator : AbstractValidator<ObtenerPacientePorIdQuery>
{
    public ObtenerPacientePorIdQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}