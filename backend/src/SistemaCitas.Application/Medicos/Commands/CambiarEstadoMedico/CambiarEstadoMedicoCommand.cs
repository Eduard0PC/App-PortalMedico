using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Medicos.Commands.CambiarEstadoMedico;

public sealed record CambiarEstadoMedicoCommand(int Id, bool Activo)
    : IRequest<MedicoDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}