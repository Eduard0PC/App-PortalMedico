import 'package:flutter/foundation.dart';
import '../../shared/models.dart';
import '../network/api_client.dart';

class MedicosRepository {
  final ApiClient _apiClient;

  MedicosRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Especialidad>> fetchEspecialidades(String token) async {
    try {
      final response = await _apiClient.get(
        '/api/especialidades',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponseData(response.body);
        if (data is List) {
          return data.map((item) => Especialidad.fromJson(item)).toList();
        }
      } else {
        debugPrint('Error status code fetching specialties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al conectar con api/especialidades: $e');
    }
    return [];
  }

  Future<List<Medico>> fetchMedicos(String token, {int? especialidadId}) async {
    try {
      final path = especialidadId != null
          ? '/api/medicos?especialidadId=$especialidadId'
          : '/api/medicos';

      final response = await _apiClient.get(
        path,
        token: token,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponseData(response.body);
        if (data is List) {
          return data.map((item) => Medico.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error al conectar con api/medicos: $e');
    }
    return [];
  }

  Future<List<String>> fetchDisponibilidad(String token, int idMedico, DateTime fecha) async {
    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final fechaStr = '$year-$month-$day';

    try {
      final response = await _apiClient.get(
        '/api/medicos/$idMedico/disponibilidad?fecha=$fechaStr',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponseData(response.body);
        if (data is List) {
          final List<String> slots = [];
          for (var item in data) {
            final rawInicio = item['horaInicio'] as String? ?? '';
            final parts = rawInicio.split(':');
            if (parts.length >= 2) {
              slots.add('${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}');
            }
          }
          return slots;
        }
      }
    } catch (e) {
      debugPrint('Error al consultar disponibilidad: $e');
    }
    return [];
  }
}
