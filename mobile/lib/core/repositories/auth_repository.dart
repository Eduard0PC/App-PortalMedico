import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

class AuthResult {
  final String token;
  final int id;
  final String nombreCompleto;
  final String correo;
  final String rol;

  AuthResult({
    required this.token,
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.rol,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String? ?? '',
      id: (json['id'] as num?)?.toInt() ?? 1,
      nombreCompleto: json['nombreCompleto'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      rol: json['rol'] as String? ?? 'Paciente',
    );
  }
}

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AuthResult> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Correo y contraseña son requeridos.');
    }

    final body = {
      'correo': email.trim(),
      'password': password,
    };

    // 1. Intentar inicio de sesión como Paciente
    try {
      final pacienteResponse = await _apiClient.post(
        '/api/auth/pacientes/login',
        body: body,
      );

      if (pacienteResponse.statusCode == 200) {
        final data = _apiClient.parseResponseData(pacienteResponse.body);
        if (data is Map<String, dynamic>) {
          return AuthResult.fromJson(data);
        } else if (data is Map) {
          return AuthResult.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint('Error al conectar con login de Paciente: $e');
    }

    // 2. Si falla paciente, intentar como Médico
    try {
      final medicoResponse = await _apiClient.post(
        '/api/auth/medicos/login',
        body: body,
      );

      if (medicoResponse.statusCode == 200) {
        final data = _apiClient.parseResponseData(medicoResponse.body);
        if (data is Map<String, dynamic>) {
          return AuthResult.fromJson(data);
        } else if (data is Map) {
          return AuthResult.fromJson(Map<String, dynamic>.from(data));
        }
      } else if (medicoResponse.statusCode == 400 || medicoResponse.statusCode == 401) {
        throw Exception(_apiClient.extractErrorMessage(medicoResponse.body, 'Credenciales incorrectas.'));
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('No se pudo establecer conexión')) {
        rethrow;
      }
      debugPrint('Error al conectar con login de Médico: $e');
      throw Exception('No se pudo establecer conexión con el servidor.');
    }

    throw Exception('Correo o contraseña incorrectos.');
  }

  Future<AuthResult> registerPaciente({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required DateTime? fechaNacimiento,
    required String password,
  }) async {
    final Map<String, dynamic> bodyMap = {
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'correo': correo.trim(),
      'password': password,
      'telefono': telefono.trim().isEmpty ? null : telefono.trim(),
    };

    if (fechaNacimiento != null) {
      final year = fechaNacimiento.year.toString();
      final month = fechaNacimiento.month.toString().padLeft(2, '0');
      final day = fechaNacimiento.day.toString().padLeft(2, '0');
      bodyMap['fechaNacimiento'] = '$year-$month-$day';
    } else {
      bodyMap['fechaNacimiento'] = null;
    }

    try {
      final response = await _apiClient.post(
        '/api/auth/pacientes/register',
        body: bodyMap,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _apiClient.parseResponseData(response.body);
        if (data is Map<String, dynamic>) {
          return AuthResult.fromJson(data);
        } else if (data is Map) {
          return AuthResult.fromJson(Map<String, dynamic>.from(data));
        }
      }
      throw Exception(_apiClient.extractErrorMessage(response.body, 'Error al registrar el paciente.'));
    } catch (e) {
      if (e is Exception && !e.toString().contains('SocketException')) {
        rethrow;
      }
      debugPrint('Error en registro: $e');
      throw Exception('No se pudo establecer conexión con el servidor.');
    }
  }
}
