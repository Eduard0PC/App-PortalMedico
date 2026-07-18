using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Citas.Commands.AtenderCita;

public sealed record AtenderCitaCommand(int Id, string NotaMedica, uint RowVersion)
    : IRequest<CitaDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Medico" };
}