namespace SistemaCitas.Application.Chat;

/// <summary>
/// Un mensaje del historial de la conversación. Rol es "user" (el paciente) o "assistant" (el
/// modelo) — mismo vocabulario que usa la API de Anthropic, para no tener que traducir formatos
/// entre capas.
/// </summary>
public sealed record MensajeChatDto(string Rol, string Contenido);

public sealed record RespuestaChatDto(string Respuesta);