using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Horarios.Commands.CrearHorario;

public sealed record CrearHorarioCommand(
    int IdMedico, int DiaSemana, TimeOnly HoraInicio, TimeOnly HoraFin)
    : IRequest<HorarioDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Administrador" };
}