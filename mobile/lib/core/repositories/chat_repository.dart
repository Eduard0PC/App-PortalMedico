import 'package:flutter/foundation.dart';
import '../../shared/models/chat_message.dart';
import '../network/api_client.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Envía la consulta actual y el historial previo al endpoint POST /api/chat/mensaje
  Future<String> enviarMensaje({
    required String token,
    required String mensaje,
    required List<ChatMessage> historial,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/chat/mensaje',
        token: token,
        timeout: const Duration(seconds: 60), // Tiempo suficiente para llamadas a herramientas MCP en OpenRouter
        body: {
          'mensaje': mensaje,
          'historial': historial.map((m) => m.toDto()).toList(),
        },
      );

      if (response.statusCode == 200) {
        final parsedData = _apiClient.parseResponseData(response.body);

        if (parsedData is Map && parsedData.containsKey('respuesta')) {
          return parsedData['respuesta'] as String? ?? 'Sin respuesta obtenida.';
        } else if (parsedData is String) {
          return parsedData;
        }

        return 'Respuesta procesada pero en formato inesperado.';
      } else {
        final errorMsg = _apiClient.extractErrorMessage(
          response.body,
          'No se pudo obtener respuesta del asistente virtual (${response.statusCode}).',
        );
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error en ChatRepository.enviarMensaje: $e');
      rethrow;
    }
  }
}
