using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Citas.Commands.CancelarCita;

public sealed record CancelarCitaCommand(int Id, uint RowVersion) : IRequest<CitaDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente", "Administrador" };
}