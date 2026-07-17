using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Especialidades.Commands.ActualizarEspecialidad;

public sealed record ActualizarEspecialidadCommand(int Id, string Nombre, string? Descripcion)
    : IRequest<EspecialidadDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}