import 'package:flutter/foundation.dart';
import '../../shared/models.dart';
import '../network/api_client.dart';

class CitasRepository {
  final ApiClient _apiClient;

  CitasRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Cita>> fetchCitas(String token) async {
    try {
      final response = await _apiClient.get(
        '/api/citas',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponseData(response.body);
        if (data is List) {
          return data.map((item) => Cita.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error al obtener citas: $e');
    }
    return [];
  }

  Future<Cita> reservarCita({
    required String token,
    required Medico medico,
    required Especialidad especialidad,
    required DateTime fecha,
    required String horaInicio,
    required String motivo,
  }) async {
    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final fechaStr = '$year-$month-$day';

    final horaInicioBackend = horaInicio.length == 5 ? '$horaInicio:00' : horaInicio;

    try {
      final response = await _apiClient.post(
        '/api/citas',
        token: token,
        body: {
          'idMedico': medico.idMedico,
          'fecha': fechaStr,
          'horaInicio': horaInicioBackend,
          'motivoConsulta': motivo,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final citaData = _apiClient.parseResponseData(response.body);
        if (citaData is Map<String, dynamic>) {
          return Cita.fromJson(citaData);
        } else if (citaData is Map) {
          return Cita.fromJson(Map<String, dynamic>.from(citaData));
        }
      }
      final errorMsg = _apiClient.extractErrorMessage(response.body, 'Error al reservar cita.');
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception && !e.toString().contains('SocketException')) {
        rethrow;
      }
      debugPrint('Error al conectar con POST /api/citas: $e');
      throw Exception('No se pudo conectar con el servidor.');
    }
  }

  Future<Cita> cancelarCita({
    required String token,
    required int idCita,
    required dynamic rowVersion,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/citas/$idCita/cancelar',
        token: token,
        body: {
          'rowVersion': rowVersion,
        },
      );

      if (response.statusCode == 200) {
        final citaData = _apiClient.parseResponseData(response.body);
        if (citaData is Map<String, dynamic>) {
          return Cita.fromJson(citaData);
        } else if (citaData is Map) {
          return Cita.fromJson(Map<String, dynamic>.from(citaData));
        }
      }
      final errorMsg = _apiClient.extractErrorMessage(response.body, 'No se pudo cancelar la cita.');
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception && !e.toString().contains('SocketException')) {
        rethrow;
      }
      debugPrint('Error al cancelar cita: $e');
      throw Exception('Error de conexión al cancelar la cita.');
    }
  }

  Future<Cita> atenderCita({
    required String token,
    required int idCita,
    required String notaMedica,
    required dynamic rowVersion,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/api/citas/$idCita/atender',
        token: token,
        body: {
          'notaMedica': notaMedica,
          'rowVersion': rowVersion,
        },
      );

      if (response.statusCode == 200) {
        final citaData = _apiClient.parseResponseData(response.body);
        if (citaData is Map<String, dynamic>) {
          return Cita.fromJson(citaData);
        } else if (citaData is Map) {
          return Cita.fromJson(Map<String, dynamic>.from(citaData));
        }
      }
      final errorMsg = _apiClient.extractErrorMessage(response.body, 'No se pudo atender la cita.');
      throw Exception(errorMsg);
    } catch (e) {
      if (e is Exception && !e.toString().contains('SocketException')) {
        rethrow;
      }
      debugPrint('Error al atender cita: $e');
      throw Exception('Error de conexión al atender la cita.');
    }
  }
}
