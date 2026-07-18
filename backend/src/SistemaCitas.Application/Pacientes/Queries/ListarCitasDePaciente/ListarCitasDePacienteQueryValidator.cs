using FluentValidation;

namespace SistemaCitas.Application.Pacientes.Queries.ListarCitasDePaciente;

public sealed class ListarCitasDePacienteQueryValidator : AbstractValidator<ListarCitasDePacienteQuery>
{
    public ListarCitasDePacienteQueryValidator()
    {
        RuleFor(x => x.Id).GreaterThan(0);
    }
}