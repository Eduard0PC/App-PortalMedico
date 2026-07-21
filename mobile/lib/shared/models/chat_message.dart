enum MessageSender { user, assistant }

class ChatMessage {
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isError = false,
  });

  /// Convierte el mensaje al DTO esperado por el backend C#:
  /// MensajeChatDto(string Rol, string Contenido)
  /// Rol debe ser "user" para el paciente o "assistant" para la IA.
  Map<String, String> toDto() {
    return {
      'rol': sender == MessageSender.user ? 'user' : 'assistant',
      'contenido': text,
    };
  }
}
