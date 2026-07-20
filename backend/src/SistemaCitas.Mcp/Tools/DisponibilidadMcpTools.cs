using System.ComponentModel;
using MediatR;
using ModelContextProtocol;
using ModelContextProtocol.Server;
using SistemaCitas.Application.Especialidades;
using SistemaCitas.Application.Especialidades.Queries.ListarEspecialidades;
using SistemaCitas.Application.Horarios;
using SistemaCitas.Application.Horarios.Queries.BuscarMedicosDisponibles;
using SistemaCitas.Application.Horarios.Queries.ObtenerDisponibilidad;
using SistemaCitas.Application.Medicos;
using SistemaCitas.Application.Medicos.Queries.ListarMedicos;

namespace SistemaCitas.Mcp.Tools;

[McpServerToolType]
public sealed class DisponibilidadMcpTools
{
    private readonly ISender _sender;

    public DisponibilidadMcpTools(ISender sender) => _sender = sender;

    [McpServerTool(Name = "listar_especialidades")]
    [Description("Lista las especialidades médicas disponibles en la clínica (ej. Pediatría, Cardiología).")]
    public async Task<List<EspecialidadDto>> ListarEspecialidades(CancellationToken ct)
        => await _sender.Send(new ListarEspecialidadesQuery(), ct);

    [McpServerTool(Name = "listar_medicos")]
    [Description("Lista los médicos de la clínica, opcionalmente filtrados por especialidad.")]
    public async Task<List<MedicoDto>> ListarMedicos(
        [Description("Id de la especialidad para filtrar (opcional)")] int? idEspecialidad,
        CancellationToken ct)
        => await _sender.Send(new ListarMedicosQuery(idEspecialidad), ct);

    [McpServerTool(Name = "obtener_disponibilidad_de_medico")]
    [Description("Devuelve los bloques de 30 minutos disponibles de un médico específico en una fecha dada.")]
    public async Task<List<BloqueDisponibleDto>> ObtenerDisponibilidadDeMedico(
        [Description("Id del médico")] int idMedico,
        [Description("Fecha en formato yyyy-MM-dd")] string fecha,
        CancellationToken ct)
    {
        if (!DateOnly.TryParse(fecha, out var fechaParseada))
            throw new McpException("La fecha debe tener formato yyyy-MM-dd.");

        return await _sender.Send(new ObtenerDisponibilidadQuery(idMedico, fechaParseada), ct);
    }

    [McpServerTool(Name = "buscar_medicos_disponibles")]
    [Description(
        "Busca qué médicos tienen un bloque disponible a una hora y fecha específicas, " +
        "opcionalmente filtrando por especialidad. Ideal para preguntas como '¿qué médicos " +
        "están disponibles a las 5pm el lunes?'.")]
    public async Task<List<MedicoDisponibleDto>> BuscarMedicosDisponibles(
        [Description("Fecha en formato yyyy-MM-dd")] string fecha,
        [Description("Hora en formato HH:mm de 24 horas (ej. 17:00 para las 5pm)")] string hora,
        [Description("Id de la especialidad para filtrar (opcional)")] int? idEspecialidad,
        CancellationToken ct)
    {
        if (!DateOnly.TryParse(fecha, out var fechaParseada))
            throw new McpException("La fecha debe tener formato yyyy-MM-dd.");

        if (!TimeOnly.TryParse(hora, out var horaParseada))
            throw new McpException("La hora debe tener formato HH:mm (24 horas).");

        return await _sender.Send(
            new BuscarMedicosDisponiblesQuery(idEspecialidad, fechaParseada, horaParseada), ct);
    }
}