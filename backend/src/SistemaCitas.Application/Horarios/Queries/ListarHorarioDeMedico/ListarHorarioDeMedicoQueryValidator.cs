using FluentValidation;

namespace SistemaCitas.Application.Horarios.Queries.ListarHorarioDeMedico;

public sealed class ListarHorarioDeMedicoQueryValidator
    : AbstractValidator<ListarHorarioDeMedicoQuery>
{
    public ListarHorarioDeMedicoQueryValidator()
    {
        RuleFor(x => x.IdMedico).GreaterThan(0);
    }
}