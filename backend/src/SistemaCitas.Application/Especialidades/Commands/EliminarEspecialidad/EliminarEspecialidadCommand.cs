using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Especialidades.Commands.EliminarEspecialidad;

public sealed record EliminarEspecialidadCommand(int Id) : IRequest, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}
