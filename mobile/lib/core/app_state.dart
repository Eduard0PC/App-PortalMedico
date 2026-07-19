import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared/models.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AppState extends ChangeNotifier {
  // Current logged in user (null if guest)
  String? _currentUserEmail;
  String? _currentUserName;
  int? _currentUserId;
  String? _userRole; // 'Paciente' o 'Medico'
  String? _token;

  bool get isLoggedIn => _currentUserEmail != null;
  String get currentUserName => _currentUserName ?? 'Usuario';
  int get currentUserId => _currentUserId ?? 0;
  String get currentUserEmail => _currentUserEmail ?? '';
  String get userRole => _userRole ?? 'Paciente';
  String? get token => _token;

  String get _backendBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5250';
    }
    return Platform.isAndroid ? 'http://10.0.2.2:5250' : 'http://localhost:5250';
  }

  // Data lists
  final List<Especialidad> _especialidades = [];
  final List<Medico> _medicos = [];
  final List<Cita> _citas = [];

  List<Especialidad> get especialidades => List.unmodifiable(_especialidades);
  List<Medico> get medicos => List.unmodifiable(_medicos);
  
  // Dynamic filtering based on logged in role
  List<Cita> get citas => _citas
      .where((c) => userRole == 'Medico' ? c.medico.idMedico == currentUserId : c.idPaciente == currentUserId)
      .toList()
    ..sort((a, b) {
      final cmp = b.fecha.compareTo(a.fecha);
      if (cmp != 0) return cmp;
      return b.horaInicio.compareTo(a.horaInicio);
    });

  AppState();

  dynamic _parseResponseData(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map && decoded.containsKey('data') && (decoded.containsKey('success') || decoded.containsKey('message'))) {
        return decoded['data'] ?? decoded;
      }
      return decoded;
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(String responseBody, String defaultMessage) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map) {
        if (decoded['data'] != null && decoded['data'] is Map) {
          final Map<String, dynamic> fieldErrors = Map<String, dynamic>.from(decoded['data']);
          final List<String> errorList = [];
          fieldErrors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.map((e) => e.toString()));
            } else if (value != null) {
              errorList.add(value.toString());
            }
          });
          if (errorList.isNotEmpty) {
            return errorList.join('\n');
          }
        }
        if (decoded['message'] != null && decoded['message'].toString().isNotEmpty) {
          return decoded['message'].toString();
        }
        if (decoded['detail'] != null && decoded['detail'].toString().isNotEmpty) {
          return decoded['detail'].toString();
        }
      }
    } catch (_) {}
    return defaultMessage;
  }

  // Authentication Actions
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return false;

    final body = jsonEncode({
      'correo': email.trim(),
      'password': password,
    });

    final headers = {
      'Content-Type': 'application/json',
    };

    // 1. Intentar iniciar sesión como Paciente
    try {
      final pacienteResponse = await http.post(
        Uri.parse('$_backendBaseUrl/api/auth/pacientes/login'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (pacienteResponse.statusCode == 200) {
        final data = _parseResponseData(pacienteResponse.body);
        _token = data['token'];
        _currentUserId = (data['id'] as num?)?.toInt() ?? 1;
        _currentUserName = data['nombreCompleto'];
        _currentUserEmail = data['correo'];
        _userRole = data['rol']; // "Paciente"
        await fetchEspecialidades();
        await fetchMedicos();
        await fetchCitas();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error al conectar con login de Paciente: $e');
    }

    // 2. Si no tiene éxito, intentar como Médico
    try {
      final medicoResponse = await http.post(
        Uri.parse('$_backendBaseUrl/api/auth/medicos/login'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (medicoResponse.statusCode == 200) {
        final data = _parseResponseData(medicoResponse.body);
        _token = data['token'];
        _currentUserId = (data['id'] as num?)?.toInt() ?? 1;
        _currentUserName = data['nombreCompleto'];
        _currentUserEmail = data['correo'];
        _userRole = data['rol']; // "Medico"
        await fetchEspecialidades();
        await fetchMedicos();
        await fetchCitas();
        notifyListeners();
        return true;
      } else if (medicoResponse.statusCode == 400 || medicoResponse.statusCode == 401) {
        throw AuthException(_extractErrorMessage(medicoResponse.body, 'Credenciales incorrectas.'));
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error al conectar con login de Médico: $e');
      throw AuthException('No se pudo establecer conexión con el servidor.');
    }

    throw AuthException('Correo o contraseña incorrectos.');
  }

  Future<void> register({
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
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/api/auth/pacientes/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyMap),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = _parseResponseData(response.body);
        _token = data['token'];
        _currentUserId = (data['id'] as num?)?.toInt() ?? 1;
        _currentUserName = data['nombreCompleto'];
        _currentUserEmail = data['correo'];
        _userRole = data['rol']; // "Paciente"
        await fetchEspecialidades();
        await fetchMedicos();
        await fetchCitas();
        notifyListeners();
      } else {
        throw AuthException(_extractErrorMessage(response.body, 'Error al registrar el paciente.'));
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      debugPrint('Error en registro: $e');
      throw AuthException('No se pudo establecer conexión con el servidor.');
    }
  }

  void logout() {
    _currentUserEmail = null;
    _currentUserName = null;
    _currentUserId = null;
    _userRole = null;
    _token = null;
    _especialidades.clear();
    _medicos.clear();
    _citas.clear();
    notifyListeners();
  }

  Future<void> fetchEspecialidades() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/api/especialidades'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = _parseResponseData(response.body);
        if (data is List) {
          _especialidades.clear();
          _especialidades.addAll(data.map((item) => Especialidad.fromJson(item)).toList());
          notifyListeners();
        }
      } else {
        debugPrint('Error status code fetching specialties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al conectar con api/especialidades: $e');
    }
  }

  Future<void> fetchMedicos({int? especialidadId}) async {
    if (_token == null) return;

    try {
      final uri = especialidadId != null
          ? Uri.parse('$_backendBaseUrl/api/medicos?especialidadId=$especialidadId')
          : Uri.parse('$_backendBaseUrl/api/medicos');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = _parseResponseData(response.body);
        if (data is List) {
          final fetched = data.map((item) => Medico.fromJson(item)).toList();
          
          if (especialidadId == null) {
            _medicos.clear();
            _medicos.addAll(fetched);
          } else {
            for (var doc in fetched) {
              final idx = _medicos.indexWhere((m) => m.idMedico == doc.idMedico);
              if (idx != -1) {
                _medicos[idx] = doc;
              } else {
                _medicos.add(doc);
              }
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error al conectar con api/medicos: $e');
    }
  }

  Future<List<String>> fetchDisponibilidad(int idMedico, DateTime fecha) async {
    if (_token == null) return [];

    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final fechaStr = '$year-$month-$day';

    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/api/medicos/$idMedico/disponibilidad?fecha=$fechaStr'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = _parseResponseData(response.body);
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

  Future<void> fetchCitas() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/api/citas'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = _parseResponseData(response.body);
        if (data is List) {
          _citas.clear();
          _citas.addAll(data.map((item) => Cita.fromJson(item)).toList());
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error al obtener citas: $e');
    }
  }

  // Appointment Actions
  Future<bool> reservarCita({
    required Medico medico,
    required Especialidad especialidad,
    required DateTime fecha,
    required String horaInicio,
    required String motivo,
  }) async {
    if (_token == null) {
      throw AuthException('Debe iniciar sesión para reservar una cita.');
    }

    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final fechaStr = '$year-$month-$day';

    final horaInicioBackend = horaInicio.length == 5 ? '$horaInicio:00' : horaInicio;

    try {
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/api/citas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'idMedico': medico.idMedico,
          'fecha': fechaStr,
          'horaInicio': horaInicioBackend,
          'motivoConsulta': motivo,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final citaData = _parseResponseData(response.body);
        if (citaData is Map<String, dynamic>) {
          final nuevaCita = Cita.fromJson(citaData);
          _citas.add(nuevaCita);
        } else if (citaData is Map) {
          final nuevaCita = Cita.fromJson(Map<String, dynamic>.from(citaData));
          _citas.add(nuevaCita);
        }
        notifyListeners();
        return true;
      } else {
        final errorMsg = _extractErrorMessage(response.body, 'Error al reservar cita.');
        throw AuthException(errorMsg);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Error al conectar con POST /api/citas: $e');
      throw AuthException('No se pudo conectar con el servidor.');
    }
  }

  Future<bool> cancelarCita(int idCita) async {
    final index = _citas.indexWhere((c) => c.idCita == idCita);
    if (index == -1) return false;

    final cita = _citas[index];
    if (!cita.esCancelable) return false;

    if (_token == null) {
      throw AuthException('Debe iniciar sesión para cancelar una cita.');
    }

    try {
      final response = await http.patch(
        Uri.parse('$_backendBaseUrl/api/citas/$idCita/cancelar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'rowVersion': cita.rowVersion,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final citaData = _parseResponseData(response.body);
        if (citaData is Map<String, dynamic>) {
          _citas[index] = Cita.fromJson(citaData);
        } else if (citaData is Map) {
          _citas[index] = Cita.fromJson(Map<String, dynamic>.from(citaData));
        }
        notifyListeners();
        return true;
      } else {
        final errorMsg = _extractErrorMessage(response.body, 'No se pudo cancelar la cita.');
        throw AuthException(errorMsg);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Error al cancelar cita: $e');
      throw AuthException('Error de conexión al cancelar la cita.');
    }
  }

  // Doctor Action
  Future<bool> atenderCita(int idCita, String notaMedica) async {
    final index = _citas.indexWhere((c) => c.idCita == idCita);
    if (index == -1) return false;

    final cita = _citas[index];

    if (_token == null) {
      throw AuthException('Debe iniciar sesión para atender una cita.');
    }

    try {
      final response = await http.patch(
        Uri.parse('$_backendBaseUrl/api/citas/$idCita/atender'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'notaMedica': notaMedica,
          'rowVersion': cita.rowVersion,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final citaData = _parseResponseData(response.body);
        if (citaData is Map<String, dynamic>) {
          _citas[index] = Cita.fromJson(citaData);
        } else if (citaData is Map) {
          _citas[index] = Cita.fromJson(Map<String, dynamic>.from(citaData));
        }
        notifyListeners();
        return true;
      } else {
        final errorMsg = _extractErrorMessage(response.body, 'No se pudo atender la cita.');
        throw AuthException(errorMsg);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Error al atender cita: $e');
      throw AuthException('Error de conexión al atender la cita.');
    }
  }

  // Patient Records Search Helpers
  List<Map<String, dynamic>> get uniquePatients {
    final patientsMap = <int, String>{};
    for (var cita in _citas) {
      if (userRole == 'Medico') {
        if (cita.medico.idMedico == currentUserId) {
          patientsMap[cita.idPaciente] = cita.nombrePaciente;
        }
      } else {
        patientsMap[cita.idPaciente] = cita.nombrePaciente;
      }
    }
    return patientsMap.entries.map((e) => {'id': e.key, 'nombre': e.value}).toList();
  }

  List<Cita> getCitasPaciente(int idPaciente) {
    return _citas.where((c) => c.idPaciente == idPaciente).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  // Profile Methods (Paciente & Medico)
  Future<Paciente?> fetchPacientePerfil(int id) async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/api/pacientes/$id'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = _parseResponseData(response.body);
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
    required int id,
    required String nombre,
    required String apellido,
    String? telefono,
    DateTime? fechaNacimiento,
  }) async {
    if (_token == null) {
      throw AuthException('Debe iniciar sesión para actualizar el perfil.');
    }

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
      final response = await http.put(
        Uri.parse('$_backendBaseUrl/api/pacientes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(bodyMap),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _currentUserName = '${nombre.trim()} ${apellido.trim()}';
        notifyListeners();
        return true;
      } else {
        final errorMsg = _extractErrorMessage(response.body, 'Error al actualizar perfil de paciente.');
        throw AuthException(errorMsg);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('Error al actualizar perfil paciente: $e');
      throw AuthException('Error de conexión al actualizar el perfil.');
    }
  }
}

// Inherited Widget Provider to propagate AppState down the tree
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}
