using MediatR;
using SistemaCitas.Application.Common.Interfaces;

namespace SistemaCitas.Application.Citas.Commands.ReservarCita;

public sealed record ReservarCitaCommand(
    int IdPaciente, int IdMedico, DateOnly Fecha, TimeOnly HoraInicio, string MotivoConsulta)
    : IRequest<CitaDto>, IAuthorizedRequest
{
    public string[] RolesPermitidos => new[] { "Paciente" };
}