using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Commands.ActualizarHorario;

public sealed record ActualizarHorarioCommand(
    int Id, int IdMedico, int DiaSemana, TimeOnly HoraInicio, TimeOnly HoraFin)
    : IRequest<HorarioDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}