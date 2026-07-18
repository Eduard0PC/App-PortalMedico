using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Especialidades.Commands.CrearEspecialidad;

public sealed record CrearEspecialidadCommand(string Nombre, string? Descripcion)
    : IRequest<EspecialidadDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}