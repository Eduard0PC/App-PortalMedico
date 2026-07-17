using MediatR;
using SistemaCitas.Domain.Exceptions;
using SistemaCitas.Domain.Interfaces;

namespace SistemaCitas.Application.Pacientes.Queries.ListarCitasDePaciente;

public sealed class ListarCitasDePacienteQueryHandler
    : IRequestHandler<ListarCitasDePacienteQuery, List<CitaDelPacienteDto>>
{
    private readonly IPacienteRepository _pacienteRepository;
    private readonly ICitaRepository _citaRepository;

    public ListarCitasDePacienteQueryHandler(
        IPacienteRepository pacienteRepository, ICitaRepository citaRepository)
    {
        _pacienteRepository = pacienteRepository;
        _citaRepository = citaRepository;
    }

    public async Task<List<CitaDelPacienteDto>> Handle(
        ListarCitasDePacienteQuery request, CancellationToken ct)
    {
        // Chequeo explícito de existencia: sin esto, un id de paciente inexistente devolvería
        // silenciosamente una lista vacía (200 OK) en vez de un 404 — la misma distinción que ya
        // hacen ObtenerPacientePorIdQuery (Paso 3) y ActualizarPerfilCommand (Paso 4).
        _ = await _pacienteRepository.ObtenerPorIdAsync(request.Id, ct)
            ?? throw new NotFoundException($"No existe un paciente con id {request.Id}.");

        var citas = await _citaRepository.ListarAsync(
            idPaciente: request.Id, idMedico: null, fecha: null, estado: null, ct);

        return citas
            .Select(c => new CitaDelPacienteDto(
                c.Id,
                c.Fecha,
                c.HoraInicio,
                c.HoraFin,
                c.MotivoConsulta,
                c.Estado.ToString(),
                c.NotaMedica,
                c.IdMedico,
                c.Medico is not null ? $"{c.Medico.Nombre} {c.Medico.Apellido}" : string.Empty,
                c.Medico?.Especialidad?.Nombre ?? string.Empty))
            .ToList();
    }
}