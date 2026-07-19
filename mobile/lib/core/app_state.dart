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
  String get currentUserName => _currentUserName ?? 'Paciente';
  int get currentUserId => _currentUserId ?? 1;
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

  AppState() {
    _loadSeedData();
  }

  void _loadSeedData() {
    // 1. Specialties - Removed to load dynamically from backend GET /api/especialidades

    // 2. Medicos
    _medicos.addAll([
      // General Medicine (Dr. Carlos Garcia is the target doctor for doctor login demo)
      // Note: idEspecialidad updated to 3 to match the backend seeded ID for Medicina General.
      const Medico(
        idMedico: 101,
        nombre: 'Carlos',
        apellido: 'García',
        correo: 'carlos.garcia@clinica.com',
        idEspecialidad: 3,
        telefono: '555-0101',
      ),
      const Medico(
        idMedico: 102,
        nombre: 'María',
        apellido: 'Fernández',
        correo: 'maria.fernandez@clinica.com',
        idEspecialidad: 3,
        telefono: '555-0102',
      ),
      // Pediatría (idEspecialidad updated to 1)
      const Medico(
        idMedico: 201,
        nombre: 'Ana',
        apellido: 'Martínez',
        correo: 'ana.martinez@clinica.com',
        idEspecialidad: 1,
        telefono: '555-0201',
      ),
      const Medico(
        idMedico: 202,
        nombre: 'Luis',
        apellido: 'Torres',
        correo: 'luis.torres@clinica.com',
        idEspecialidad: 1,
        telefono: '555-0202',
      ),
      // Cardiología (idEspecialidad updated to 2)
      const Medico(
        idMedico: 301,
        nombre: 'Roberto',
        apellido: 'Sánchez',
        correo: 'roberto.sanchez@clinica.com',
        idEspecialidad: 2,
        telefono: '555-0301',
      ),
      // Dermatología
      const Medico(
        idMedico: 401,
        nombre: 'Elena',
        apellido: 'Gómez',
        correo: 'elena.gomez@clinica.com',
        idEspecialidad: 4,
        telefono: '555-0401',
      ),
      // Odontología
      const Medico(
        idMedico: 501,
        nombre: 'Jorge',
        apellido: 'Ruiz',
        correo: 'jorge.ruiz@clinica.com',
        idEspecialidad: 5,
        telefono: '555-0501',
      ),
    ]);

    // 3. Mock Appointments
    final today = DateTime.now();
    // A past appointment (yesterday)
    final yesterday = today.subtract(const Duration(days: 1));
    _citas.add(Cita(
      idCita: 1001,
      idPaciente: 1,
      nombrePaciente: 'Eduardo García',
      medico: _medicos[0], // Carlos Garcia - General Medicine
      especialidad: const Especialidad(
        idEspecialidad: 3,
        nombre: 'Medicina General',
        descripcion: 'Consulta y control de salud general',
      ),
      fecha: DateTime(yesterday.year, yesterday.month, yesterday.day),
      horaInicio: '09:00',
      horaFin: '09:30',
      motivoConsulta: 'Chequeo anual de rutina.',
      estado: 'Atendida',
      notaMedica: 'Paciente saludable. Presión arterial óptima. Se sugiere continuar dieta baja en sodio.',
    ));

    // A future appointment (tomorrow, can cancel)
    final tomorrow = today.add(const Duration(days: 1));
    _citas.add(Cita(
      idCita: 1002,
      idPaciente: 1,
      nombrePaciente: 'Eduardo García',
      medico: _medicos[2], // Ana Martinez - Pediatria
      especialidad: const Especialidad(
        idEspecialidad: 1,
        nombre: 'Pediatría',
        descripcion: 'Atención médica para niños y adolescentes',
      ),
      fecha: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      horaInicio: '10:30',
      horaFin: '11:00',
      motivoConsulta: 'Consulta de control de crecimiento.',
      estado: 'Programada',
    ));

    // A near appointment (today in 2 hours, cannot cancel because it is less than 24h)
    final nearCitaTime = today.add(const Duration(hours: 2));
    final nearCitaHourStr = '${nearCitaTime.hour.toString().padLeft(2, '0')}:00';
    final nearCitaHourEndStr = '${nearCitaTime.hour.toString().padLeft(2, '0')}:30';
    _citas.add(Cita(
      idCita: 1003,
      idPaciente: 1,
      nombrePaciente: 'Eduardo García',
      medico: _medicos[4], // Roberto Sanchez - Cardiologia
      especialidad: const Especialidad(
        idEspecialidad: 2,
        nombre: 'Cardiología',
        descripcion: 'Diagnóstico y tratamiento de enfermedades del corazón',
      ),
      fecha: DateTime(today.year, today.month, today.day),
      horaInicio: nearCitaHourStr,
      horaFin: nearCitaHourEndStr,
      motivoConsulta: 'Lectura de electrocardiograma.',
      estado: 'Programada',
    ));

    // 4. Seeding appointments for Doctor Carlos García (101) dynamic current-week schedule
    final todayOnlyDate = DateTime(today.year, today.month, today.day);
    final monday = todayOnlyDate.subtract(Duration(days: todayOnlyDate.weekday - 1));
    final tuesday = monday.add(const Duration(days: 1));
    final wednesday = monday.add(const Duration(days: 2));
    final thursday = monday.add(const Duration(days: 3));
    final friday = monday.add(const Duration(days: 4));

    // Monday: Atendida
    _citas.add(Cita(
      idCita: 2001,
      idPaciente: 10,
      nombrePaciente: 'Juan Pérez',
      medico: _medicos[0], // Dr. Carlos García
      especialidad: const Especialidad(
        idEspecialidad: 3,
        nombre: 'Medicina General',
        descripcion: 'Consulta y control de salud general',
      ),
      fecha: monday,
      horaInicio: '09:00',
      horaFin: '09:30',
      motivoConsulta: 'Dolor de garganta y fiebre.',
      estado: 'Atendida',
      notaMedica: 'Faringitis aguda. Se receta amoxicilina 500mg cada 8 horas por 7 días y reposo.',
    ));

    // Tuesday: Atendida
    _citas.add(Cita(
      idCita: 2002,
      idPaciente: 11,
      nombrePaciente: 'María López',
      medico: _medicos[0], // Dr. Carlos García
      especialidad: const Especialidad(
        idEspecialidad: 3,
        nombre: 'Medicina General',
        descripcion: 'Consulta y control de salud general',
      ),
      fecha: tuesday,
      horaInicio: '14:30',
      horaFin: '15:00',
      motivoConsulta: 'Control de hipertensión.',
      estado: 'Atendida',
      notaMedica: 'Presión controlada 120/80. Continuar con losartan 50mg diario. Próximo control en 3 meses.',
    ));

    // Wednesday: Programada
    _citas.add(Cita(
      idCita: 2003,
      idPaciente: 12,
      nombrePaciente: 'Laura Gómez',
      medico: _medicos[0], // Dr. Carlos García
      especialidad: const Especialidad(
        idEspecialidad: 3,
        nombre: 'Medicina General',
        descripcion: 'Consulta y control de salud general',
      ),
      fecha: wednesday,
      horaInicio: '10:00',
      horaFin: '10:30',
      motivoConsulta: 'Revisión de laboratorios.',
      estado: 'Programada',
    ));

    // Thursday: Programada
    _citas.add(Cita(
      idCita: 2004,
      idPaciente: 13,
      nombrePaciente: 'Pedro Ruiz',
      medico: _medicos[0], // Dr. Carlos García
      especialidad: const Especialidad(
        idEspecialidad: 3,
        nombre: 'Medicina General',
        descripcion: 'Consulta y control de salud general',
      ),
      fecha: thursday,
      horaInicio: '11:30',
      horaFin: '12:00',
      motivoConsulta: 'Migraña recurrente.',
      estado: 'Programada',
    ));

    // Friday: Programada
    _citas.add(Cita(
      idCita: 2005,
      idPaciente: 14,
      nombrePaciente: 'Sofía Rodríguez',
      medico: _medicos[0], // Dr. Carlos García
      especialidad: const Especialidad(
        idEspecialidad: 3,
        nombre: 'Medicina General',
        descripcion: 'Consulta y control de salud general',
      ),
      fecha: friday,
      horaInicio: '16:00',
      horaFin: '16:30',
      motivoConsulta: 'Chequeo general preventivo.',
      estado: 'Programada',
    ));
  }

  // Authentication Actions
  Future<bool> login(String email, String password, {bool isDemo = false, String? demoRole}) async {
    if (isDemo) {
      if (demoRole == 'Medico') {
        _currentUserEmail = 'carlos.garcia@clinica.com';
        _currentUserName = 'Carlos García';
        _currentUserId = 101; // Dr. Carlos García
        _userRole = 'Medico';
        _token = 'demo-token';
      } else {
        _currentUserEmail = 'paciente.demo@gmail.com';
        _currentUserName = 'Eduardo García';
        _currentUserId = 1;
        _userRole = 'Paciente';
        _token = 'demo-token';
        await fetchEspecialidades();
      }
      notifyListeners();
      return true;
    }

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
        final data = jsonDecode(pacienteResponse.body);
        _token = data['token'];
        _currentUserId = data['id'];
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
        final data = jsonDecode(medicoResponse.body);
        _token = data['token'];
        _currentUserId = data['id'];
        _currentUserName = data['nombreCompleto'];
        _currentUserEmail = data['correo'];
        _userRole = data['rol']; // "Medico"
        notifyListeners();
        return true;
      } else if (medicoResponse.statusCode == 400 || medicoResponse.statusCode == 401) {
        final Map<String, dynamic> errorBody = jsonDecode(medicoResponse.body);
        final String message = errorBody['message'] ?? errorBody['detail'] ?? 'Credenciales incorrectas.';
        throw AuthException(message);
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
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUserId = data['id'];
        _currentUserName = data['nombreCompleto'];
        _currentUserEmail = data['correo'];
        _userRole = data['rol']; // "Paciente"
        await fetchEspecialidades();
        await fetchMedicos();
        await fetchCitas();
        notifyListeners();
      } else {
        final data = jsonDecode(response.body);
        final errorMsg = data['message'] ?? data['detail'] ?? 'Error al registrar el paciente.';
        throw AuthException(errorMsg);
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
    notifyListeners();
  }

  Future<void> fetchEspecialidades() async {
    if (_token == null || _token == 'demo-token') {
      _loadFallbackEspecialidades();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/api/especialidades'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _especialidades.clear();
        _especialidades.addAll(data.map((item) => Especialidad.fromJson(item)).toList());
        notifyListeners();
      } else {
        debugPrint('Error status code fetching specialties: ${response.statusCode}');
        _loadFallbackEspecialidades();
      }
    } catch (e) {
      debugPrint('Error al conectar con api/especialidades: $e');
      _loadFallbackEspecialidades();
    }
  }

  void _loadFallbackEspecialidades() {
    if (_especialidades.isNotEmpty) return;
    _especialidades.addAll([
      const Especialidad(
        idEspecialidad: 3,
        nombre: 'Medicina General',
        descripcion: 'Consulta y control de salud general',
      ),
      const Especialidad(
        idEspecialidad: 1,
        nombre: 'Pediatría',
        descripcion: 'Atención médica para niños y adolescentes',
      ),
      const Especialidad(
        idEspecialidad: 2,
        nombre: 'Cardiología',
        descripcion: 'Diagnóstico y tratamiento de enfermedades del corazón',
      ),
    ]);
    notifyListeners();
  }

  Future<void> fetchMedicos({int? especialidadId}) async {
    if (_token == null || _token == 'demo-token') return;

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
        final List<dynamic> data = jsonDecode(response.body);
        final fetched = data.map((item) => Medico.fromJson(item)).toList();
        
        for (var doc in fetched) {
          final idx = _medicos.indexWhere((m) => m.idMedico == doc.idMedico);
          if (idx != -1) {
            _medicos[idx] = doc;
          } else {
            _medicos.add(doc);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al conectar con api/medicos: $e');
    }
  }

  Future<List<String>> fetchDisponibilidad(int idMedico, DateTime fecha) async {
    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final fechaStr = '$year-$month-$day';

    if (_token == null || _token == 'demo-token') {
      final medico = _medicos.firstWhere((m) => m.idMedico == idMedico, orElse: () => _medicos.first);
      return getAvailableSlots(medico, fecha);
    }

    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/api/medicos/$idMedico/disponibilidad?fecha=$fechaStr'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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
    } catch (e) {
      debugPrint('Error al consultar disponibilidad: $e');
    }

    final medico = _medicos.firstWhere((m) => m.idMedico == idMedico, orElse: () => _medicos.first);
    return getAvailableSlots(medico, fecha);
  }

  Future<void> fetchCitas() async {
    if (_token == null || _token == 'demo-token') return;

    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/api/citas'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _citas.clear();
        _citas.addAll(data.map((item) => Cita.fromJson(item)).toList());
        notifyListeners();
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
    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    final fechaStr = '$year-$month-$day';

    final horaInicioBackend = horaInicio.length == 5 ? '$horaInicio:00' : horaInicio;

    if (_token != null && _token != 'demo-token') {
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
          final data = jsonDecode(response.body);
          final nuevaCita = Cita.fromJson(data);
          _citas.add(nuevaCita);
          notifyListeners();
          return true;
        } else {
          final data = jsonDecode(response.body);
          final errorMsg = data['message'] ?? data['detail'] ?? 'Error al reservar cita.';
          throw AuthException(errorMsg);
        }
      } catch (e) {
        if (e is AuthException) rethrow;
        debugPrint('Error al conectar con POST /api/citas: $e');
        throw AuthException('No se pudo conectar con el servidor.');
      }
    }

    // Fallback demo
    final parts = horaInicio.split(':');
    final hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    var endMin = min + 30;
    var endHour = hour;
    if (endMin >= 60) {
      endMin = 0;
      endHour = hour + 1;
    }
    final horaFin = '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';

    final nuevaCita = Cita(
      idCita: DateTime.now().millisecondsSinceEpoch,
      idPaciente: currentUserId,
      nombrePaciente: currentUserName,
      medico: medico,
      especialidad: especialidad,
      fecha: DateTime(fecha.year, fecha.month, fecha.day),
      horaInicio: horaInicio,
      horaFin: horaFin,
      motivoConsulta: motivo,
      estado: 'Programada',
    );

    _citas.add(nuevaCita);
    notifyListeners();
    return true;
  }

  Future<bool> cancelarCita(int idCita) async {
    final index = _citas.indexWhere((c) => c.idCita == idCita);
    if (index == -1) return false;

    final cita = _citas[index];
    if (!cita.esCancelable) return false;

    if (_token != null && _token != 'demo-token') {
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
          final data = jsonDecode(response.body);
          _citas[index] = Cita.fromJson(data);
          notifyListeners();
          return true;
        } else {
          final data = jsonDecode(response.body);
          final errorMsg = data['message'] ?? data['detail'] ?? 'No se pudo cancelar la cita.';
          throw AuthException(errorMsg);
        }
      } catch (e) {
        if (e is AuthException) rethrow;
        debugPrint('Error al cancelar cita: $e');
        throw AuthException('Error de conexión al cancelar la cita.');
      }
    }

    _citas[index] = cita.copyWith(
      estado: 'Cancelada',
      canceladaPor: 'Paciente',
    );
    notifyListeners();
    return true;
  }

  // Doctor Action
  void atenderCita(int idCita, String notaMedica) {
    final index = _citas.indexWhere((c) => c.idCita == idCita);
    if (index != -1) {
      final cita = _citas[index];
      _citas[index] = cita.copyWith(
        estado: 'Atendida',
        notaMedica: notaMedica,
      );
      notifyListeners();
    }
  }

  // Patient Records Search Helpers
  List<Map<String, dynamic>> get uniquePatients {
    final patientsMap = <int, String>{};
    for (var cita in _citas) {
      // If we are logged in as a Doctor, only show patients who have had appointments with this doctor
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

  // Business Logic: get available blocks of 30 mins
  List<String> getAvailableSlots(Medico medico, DateTime date) {
    final baseSlots = [
      '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
      '16:00', '16:30', '17:00', '17:30'
    ];

    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return [];
    }

    final bookedSlots = _citas
        .where((c) =>
            c.medico.idMedico == medico.idMedico &&
            c.fecha.year == date.year &&
            c.fecha.month == date.month &&
            c.fecha.day == date.day &&
            c.estado != 'Cancelada')
        .map((c) => c.horaInicio)
        .toSet();

    final available = baseSlots.where((slot) => !bookedSlots.contains(slot)).toList();

    final today = DateTime.now();
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return available.where((slot) {
        final parts = slot.split(':');
        final hour = int.parse(parts[0]);
        final min = int.parse(parts[1]);
        final slotTime = DateTime(today.year, today.month, today.day, hour, min);
        return slotTime.isAfter(today);
      }).toList();
    }

    return available;
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
