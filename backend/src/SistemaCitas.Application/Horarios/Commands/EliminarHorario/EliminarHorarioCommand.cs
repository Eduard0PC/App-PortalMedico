using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Commands.EliminarHorario;

public sealed record EliminarHorarioCommand(int Id, int IdMedico) : IRequest, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}