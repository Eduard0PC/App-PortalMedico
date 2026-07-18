using FluentValidation;
using SistemaCitas.Domain.Enums;

namespace SistemaCitas.Application.Citas.Queries.ListarCitas;

public sealed class ListarCitasQueryValidator : AbstractValidator<ListarCitasQuery>
{
    public ListarCitasQueryValidator()
    {
        RuleFor(x => x.PacienteId).GreaterThan(0).When(x => x.PacienteId is not null);
        RuleFor(x => x.MedicoId).GreaterThan(0).When(x => x.MedicoId is not null);

        RuleFor(x => x.Estado)
            .Must(estado => Enum.TryParse<EstadoCita>(estado, ignoreCase: true, out _))
            .When(x => x.Estado is not null)
            .WithMessage("Estado debe ser uno de: Programada, Atendida, Cancelada.");
    }
}