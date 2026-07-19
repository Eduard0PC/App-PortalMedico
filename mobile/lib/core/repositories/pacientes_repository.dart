import 'package:flutter/foundation.dart';
import '../../shared/models.dart';
import '../network/api_client.dart';

class PacientesRepository {
  final ApiClient _apiClient;

  PacientesRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Paciente?> fetchPacientePerfil(String token, int id) async {
    try {
      final response = await _apiClient.get(
        '/api/pacientes/$id',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = _apiClient.parseResponseData(response.body);
        if (data is Map<String, dynamic>) {
          return Paciente.fromJson(data);
        } else if (data is Map) {
          return Paciente.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint('Error al obtener perfil de paciente: $e');
    }
    return null;
  }

  Future<bool> actualizarPacientePerfil({
    required String token,
    required int id,
    required String nombre,
    required String apellido,
    String? telefono,
    DateTime? fechaNacimiento,
  }) async {
    final bodyMap = <String, dynamic>{
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'telefono': telefono != null && telefono.trim().isNotEmpty ? telefono.trim() : null,
    };

    if (fechaNacimiento != null) {
      final y = fechaNacimiento.year.toString();
      final m = fechaNacimiento.month.toString().padLeft(2, '0');
      final d = fechaNacimiento.day.toString().padLeft(2, '0');
      bodyMap['fechaNacimiento'] = '$y-$m-$d';
    } else {
      bodyMap['fechaNacimiento'] = null;
    }

    try {
      final response = await _apiClient.put(
        '/api/pacientes/$id',
        token: token,
        body: bodyMap,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMsg = _apiClient.extractErrorMessage(response.body, 'Error al actualizar perfil de paciente.');
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('SocketException')) {
        rethrow;
      }
      debugPrint('Error al actualizar perfil paciente: $e');
      throw Exception('Error de conexión al actualizar el perfil.');
    }
  }
}
