using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Nodes;
using SistemaCitas.Application.Chat;
using SistemaCitas.Application.Common.Interfaces;
using SistemaCitas.Mcp.Tools;

namespace SistemaCitas.Infrastructure.Chat;

public sealed class AnthropicChatService : IChatService
{
    private const string Modelo = "claude-sonnet-5";
    private const int MaxIteracionesDeHerramientas = 5;

    private const string SystemPrompt =
        "Eres el asistente virtual de una clínica médica. Tu única función es ayudar a pacientes " +
        "ya autenticados a consultar especialidades, médicos y disponibilidad de horarios, usando " +
        "las herramientas que tienes disponibles. Nunca inventes médicos, horarios ni datos que no " +
        "vengan de una herramienta. No puedes reservar, cancelar ni modificar citas. si el " +
        "paciente lo pide, indicale que lo haga desde la sección de Citas de la app. Responde " +
        "siempre en español, de forma breve, clara y amable.";

    private readonly HttpClient _httpClient;
    private readonly DisponibilidadMcpTools _tools;

    public AnthropicChatService(HttpClient httpClient, DisponibilidadMcpTools tools)
    {
        _httpClient = httpClient;
        _tools = tools;
    }

    public async Task<string> ObtenerRespuestaAsync(
        string mensaje, List<MensajeChatDto> historial, CancellationToken ct)
    {
        var mensajes = new JsonArray();

        foreach (var m in historial)
            mensajes.Add(new JsonObject { ["role"] = m.Rol, ["content"] = m.Contenido });

        mensajes.Add(new JsonObject { ["role"] = "user", ["content"] = mensaje });

        for (var iteracion = 0; iteracion < MaxIteracionesDeHerramientas; iteracion++)
        {
            var body = new JsonObject
            {
                ["model"] = Modelo,
                ["max_tokens"] = 1024,
                ["system"] = SystemPrompt,
                ["messages"] = mensajes.DeepClone(),
                ["tools"] = ConstruirDefinicionDeHerramientas(),
            };

            using var respuestaHttp = await _httpClient.PostAsJsonAsync("v1/messages", body, ct);
            respuestaHttp.EnsureSuccessStatusCode();

            var json = await respuestaHttp.Content.ReadFromJsonAsync<JsonObject>(cancellationToken: ct)
                ?? throw new InvalidOperationException("Respuesta vacía de la API de Anthropic.");

            var stopReason = json["stop_reason"]?.GetValue<string>();
            var contenido = json["content"]!.AsArray();

            // Guarda el turno del asistente tal como vino (puede traer texto + pedidos de herramienta)
            mensajes.Add(new JsonObject { ["role"] = "assistant", ["content"] = contenido.DeepClone() });

            if (stopReason != "tool_use")
            {
                return string.Concat(contenido
                    .Where(b => b!["type"]!.GetValue<string>() == "text")
                    .Select(b => b!["text"]!.GetValue<string>()));
            }

            var resultadosDeHerramientas = new JsonArray();

            foreach (var bloque in contenido)
            {
                if (bloque!["type"]!.GetValue<string>() != "tool_use")
                    continue;

                var nombreHerramienta = bloque["name"]!.GetValue<string>();
                var idLlamada = bloque["id"]!.GetValue<string>();
                var entrada = bloque["input"]!.AsObject();

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

                resultadosDeHerramientas.Add(new JsonObject
                {
                    ["type"] = "tool_result",
                    ["tool_use_id"] = idLlamada,
                    ["content"] = resultadoTexto,
                });
            }

            mensajes.Add(new JsonObject { ["role"] = "user", ["content"] = resultadosDeHerramientas });
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
        new JsonObject
        {
            ["name"] = "listar_especialidades",
            ["description"] = "Lista las especialidades médicas disponibles en la clínica.",
            ["input_schema"] = new JsonObject
            {
                ["type"] = "object",
                ["properties"] = new JsonObject(),
            },
        },
        new JsonObject
        {
            ["name"] = "listar_medicos",
            ["description"] = "Lista los médicos de la clínica, opcionalmente filtrados por especialidad.",
            ["input_schema"] = new JsonObject
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
            },
        },
        new JsonObject
        {
            ["name"] = "obtener_disponibilidad_de_medico",
            ["description"] =
                "Devuelve los bloques de 30 minutos disponibles de un médico específico en una fecha dada.",
            ["input_schema"] = new JsonObject
            {
                ["type"] = "object",
                ["properties"] = new JsonObject
                {
                    ["idMedico"] = new JsonObject { ["type"] = "integer", ["description"] = "Id del médico" },
                    ["fecha"] = new JsonObject { ["type"] = "string", ["description"] = "Fecha en formato yyyy-MM-dd" },
                },
                ["required"] = new JsonArray { "idMedico", "fecha" },
            },
        },
        new JsonObject
        {
            ["name"] = "buscar_medicos_disponibles",
            ["description"] =
                "Busca qué médicos tienen un bloque disponible a una hora y fecha específicas, " +
                "opcionalmente filtrando por especialidad. Usala para preguntas del estilo " +
                "'¿qué médicos están disponibles a las 5pm el lunes?'.",
            ["input_schema"] = new JsonObject
            {
                ["type"] = "object",
                ["properties"] = new JsonObject
                {
                    ["fecha"] = new JsonObject { ["type"] = "string", ["description"] = "Fecha en formato yyyy-MM-dd" },
                    ["hora"] = new JsonObject { ["type"] = "string", ["description"] = "Hora en formato HH:mm de 24 horas (ej. 17:00 para las 5pm)" },
                    ["idEspecialidad"] = new JsonObject { ["type"] = "integer", ["description"] = "Id de la especialidad para filtrar (opcional)" },
                },
                ["required"] = new JsonArray { "fecha", "hora" },
            },
        },
    };
}