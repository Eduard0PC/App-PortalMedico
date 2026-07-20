using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.Extensions.Configuration;
using SistemaCitas.Application.Chat;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Mcp.Tools;

namespace SistemaCitas.Infrastructure.Chat;

/// <summary>
/// Implementa IChatService hablando con OpenRouter (https://openrouter.ai), que expone un
/// endpoint compatible con el formato de OpenAI — el mismo contrato que usan la mayoría de los
/// proveedores "en la nube", incluido Qwen. El modelo concreto se lee de configuración
/// (OpenRouter:Model) en vez de quedar fijo en el código, para poder cambiarlo sin recompilar.
/// </summary>
public sealed class OpenRouterChatService : IChatService
{
    private const int MaxIteracionesDeHerramientas = 5;

    private const string SystemPrompt =
        "Sos el asistente virtual de una clínica médica. Tu única función es ayudar a pacientes " +
        "ya autenticados a consultar especialidades, médicos y disponibilidad de horarios, usando " +
        "las herramientas que tenés disponibles. Nunca inventes médicos, horarios ni datos que no " +
        "vengan de una herramienta. No podés reservar, cancelar ni modificar citas — si el " +
        "paciente lo pide, indicale que lo haga desde la sección de Citas de la app. Respondé " +
        "siempre en español, de forma breve, clara y amable.";

    private readonly HttpClient _httpClient;
    private readonly DisponibilidadMcpTools _tools;
    private readonly string _modelo;

    public OpenRouterChatService(
        HttpClient httpClient, DisponibilidadMcpTools tools, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _tools = tools;
        _modelo = configuration["OpenRouter:Model"] ?? "qwen/qwen3-coder:free";
    }

    public async Task<string> ObtenerRespuestaAsync(
        string mensaje, List<MensajeChatDto> historial, CancellationToken ct)
    {
        var mensajes = new JsonArray
        {
            new JsonObject { ["role"] = "system", ["content"] = SystemPrompt },
        };

        foreach (var m in historial)
            mensajes.Add(new JsonObject { ["role"] = m.Rol, ["content"] = m.Contenido });

        mensajes.Add(new JsonObject { ["role"] = "user", ["content"] = mensaje });

        for (var iteracion = 0; iteracion < MaxIteracionesDeHerramientas; iteracion++)
        {
            var body = new JsonObject
            {
                ["model"] = _modelo,
                ["messages"] = mensajes.DeepClone(),
                ["tools"] = ConstruirDefinicionDeHerramientas(),
            };

            using var respuestaHttp = await _httpClient.PostAsJsonAsync("chat/completions", body, ct);

            if (!respuestaHttp.IsSuccessStatusCode)
            {
                var detalleError = await respuestaHttp.Content.ReadAsStringAsync(ct);
                throw new HttpRequestException(
                    $"OpenRouter respondió {(int)respuestaHttp.StatusCode} {respuestaHttp.StatusCode}: {detalleError}");
            }

            var json = await respuestaHttp.Content.ReadFromJsonAsync<JsonObject>(cancellationToken: ct)
                ?? throw new InvalidOperationException("Respuesta vacía de la API de OpenRouter.");

            var primeraOpcion = json["choices"]!.AsArray()[0]!.AsObject();
            var finishReason = primeraOpcion["finish_reason"]?.GetValue<string>();
            var mensajeAsistente = primeraOpcion["message"]!.AsObject();

            // Guarda el turno del asistente tal como vino (puede traer texto y/o tool_calls)
            mensajes.Add(mensajeAsistente.DeepClone());

            var toolCalls = mensajeAsistente["tool_calls"]?.AsArray();

            if (finishReason != "tool_calls" || toolCalls is null || toolCalls.Count == 0)
                return mensajeAsistente["content"]?.GetValue<string>() ?? string.Empty;

            foreach (var toolCall in toolCalls)
            {
                var idLlamada = toolCall!["id"]!.GetValue<string>();
                var funcion = toolCall["function"]!.AsObject();
                var nombreHerramienta = funcion["name"]!.GetValue<string>();
                var argumentosCrudos = funcion["arguments"]!.GetValue<string>();
                var entrada = string.IsNullOrWhiteSpace(argumentosCrudos)
                    ? new JsonObject()
                    : JsonNode.Parse(argumentosCrudos)!.AsObject();

                string resultadoTexto;
                try
                {
                    resultadoTexto = await EjecutarHerramientaAsync(nombreHerramienta, entrada, ct);
                }
                catch (Exception ex)
                {
                    // Un error acá (ej. fecha inválida) se le muestra al modelo como texto, no
                    // como una excepción .NET — así el modelo puede pedirle una aclaración al
                    // paciente en vez de que el request completo falle.
                    resultadoTexto = $"Error ejecutando la herramienta: {ex.Message}";
                }

                mensajes.Add(new JsonObject
                {
                    ["role"] = "tool",
                    ["tool_call_id"] = idLlamada,
                    ["content"] = resultadoTexto,
                });
            }
        }

        return "No pude completar la consulta en este momento. Probá reformular tu pregunta o " +
               "intentalo de nuevo en unos minutos.";
    }

    private async Task<string> EjecutarHerramientaAsync(
        string nombre, JsonObject entrada, CancellationToken ct)
    {
        object resultado = nombre switch
        {
            "listar_especialidades" =>
                await _tools.ListarEspecialidades(ct),

            "listar_medicos" =>
                await _tools.ListarMedicos(LeerIntOpcional(entrada, "idEspecialidad"), ct),

            "obtener_disponibilidad_de_medico" =>
                await _tools.ObtenerDisponibilidadDeMedico(
                    entrada["idMedico"]!.GetValue<int>(),
                    entrada["fecha"]!.GetValue<string>(),
                    ct),

            "buscar_medicos_disponibles" =>
                await _tools.BuscarMedicosDisponibles(
                    entrada["fecha"]!.GetValue<string>(),
                    entrada["hora"]!.GetValue<string>(),
                    LeerIntOpcional(entrada, "idEspecialidad"),
                    ct),

            _ => throw new InvalidOperationException($"Herramienta desconocida: {nombre}"),
        };

        return JsonSerializer.Serialize(resultado);
    }

    private static int? LeerIntOpcional(JsonObject entrada, string clave) =>
        entrada.TryGetPropertyValue(clave, out var valor) && valor is not null
            ? valor.GetValue<int>()
            : null;

    private static JsonArray ConstruirDefinicionDeHerramientas() => new()
    {
        ConstruirHerramienta(
            "listar_especialidades",
            "Lista las especialidades médicas disponibles en la clínica.",
            new JsonObject { ["type"] = "object", ["properties"] = new JsonObject() }),

        ConstruirHerramienta(
            "listar_medicos",
            "Lista los médicos de la clínica, opcionalmente filtrados por especialidad.",
            new JsonObject
            {
                ["type"] = "object",
                ["properties"] = new JsonObject
                {
                    ["idEspecialidad"] = new JsonObject
                    {
                        ["type"] = "integer",
                        ["description"] = "Id de la especialidad para filtrar (opcional)",
                    },
                },
            }),

        ConstruirHerramienta(
            "obtener_disponibilidad_de_medico",
            "Devuelve los bloques de 30 minutos disponibles de un médico específico en una fecha dada.",
            new JsonObject
            {
                ["type"] = "object",
                ["properties"] = new JsonObject
                {
                    ["idMedico"] = new JsonObject { ["type"] = "integer", ["description"] = "Id del médico" },
                    ["fecha"] = new JsonObject { ["type"] = "string", ["description"] = "Fecha en formato yyyy-MM-dd" },
                },
                ["required"] = new JsonArray { "idMedico", "fecha" },
            }),

        ConstruirHerramienta(
            "buscar_medicos_disponibles",
            "Busca qué médicos tienen un bloque disponible a una hora y fecha específicas, " +
            "opcionalmente filtrando por especialidad. Usala para preguntas del estilo " +
            "'¿qué médicos están disponibles a las 5pm el lunes?'.",
            new JsonObject
            {
                ["type"] = "object",
                ["properties"] = new JsonObject
                {
                    ["fecha"] = new JsonObject { ["type"] = "string", ["description"] = "Fecha en formato yyyy-MM-dd" },
                    ["hora"] = new JsonObject { ["type"] = "string", ["description"] = "Hora en formato HH:mm de 24 horas (ej. 17:00 para las 5pm)" },
                    ["idEspecialidad"] = new JsonObject { ["type"] = "integer", ["description"] = "Id de la especialidad para filtrar (opcional)" },
                },
                ["required"] = new JsonArray { "fecha", "hora" },
            }),
    };

    private static JsonObject ConstruirHerramienta(string nombre, string descripcion, JsonObject parametros) =>
        new()
        {
            ["type"] = "function",
            ["function"] = new JsonObject
            {
                ["name"] = nombre,
                ["description"] = descripcion,
                ["parameters"] = parametros,
            },
        };
}