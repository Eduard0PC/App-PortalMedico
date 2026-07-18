using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Citas.Commands.ReagendarCita;

public sealed record ReagendarCitaCommand(int Id, DateOnly Fecha, TimeOnly HoraInicio, uint RowVersion)
    : IRequest<CitaDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}