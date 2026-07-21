import 'package:flutter/material.dart';
import '../shared/models.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/citas_repository.dart';
import 'repositories/medicos_repository.dart';
import 'repositories/pacientes_repository.dart';
import '../shared/models/chat_message.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AppState extends ChangeNotifier {
  final AuthRepository _authRepository;
  final MedicosRepository _medicosRepository;
  final CitasRepository _citasRepository;
  final PacientesRepository _pacientesRepository;
  final ChatRepository _chatRepository;

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

  AppState({
    AuthRepository? authRepository,
    MedicosRepository? medicosRepository,
    CitasRepository? citasRepository,
    PacientesRepository? pacientesRepository,
    ChatRepository? chatRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _medicosRepository = medicosRepository ?? MedicosRepository(),
        _citasRepository = citasRepository ?? CitasRepository(),
        _pacientesRepository = pacientesRepository ?? PacientesRepository(),
        _chatRepository = chatRepository ?? ChatRepository();

  // Authentication Actions
  Future<bool> login(String email, String password) async {
    try {
      final result = await _authRepository.login(email, password);
      _token = result.token;
      _currentUserId = result.id;
      _currentUserName = result.nombreCompleto;
      _currentUserEmail = result.correo;
      _userRole = result.rol;

      await fetchEspecialidades();
      await fetchMedicos();
      await fetchCitas();
      notifyListeners();
      return true;
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required DateTime? fechaNacimiento,
    required String password,
  }) async {
    try {
      final result = await _authRepository.registerPaciente(
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
        password: password,
      );
      _token = result.token;
      _currentUserId = result.id;
      _currentUserName = result.nombreCompleto;
      _currentUserEmail = result.correo;
      _userRole = result.rol;

      await fetchEspecialidades();
      await fetchMedicos();
      await fetchCitas();
      notifyListeners();
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
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
    final items = await _medicosRepository.fetchEspecialidades(_token!);
    if (items.isNotEmpty) {
      _especialidades.clear();
      _especialidades.addAll(items);
      notifyListeners();
    }
  }

  Future<void> fetchMedicos({int? especialidadId}) async {
    if (_token == null) return;
    final items = await _medicosRepository.fetchMedicos(_token!, especialidadId: especialidadId);
    if (especialidadId == null) {
      _medicos.clear();
      _medicos.addAll(items);
    } else {
      for (var doc in items) {
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

  Future<List<String>> fetchDisponibilidad(int idMedico, DateTime fecha) async {
    if (_token == null) return [];
    return await _medicosRepository.fetchDisponibilidad(_token!, idMedico, fecha);
  }

  Future<void> fetchCitas() async {
    if (_token == null) return;
    final items = await _citasRepository.fetchCitas(_token!);
    _citas.clear();
    _citas.addAll(items);
    notifyListeners();
  }

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
    try {
      final nuevaCita = await _citasRepository.reservarCita(
        token: _token!,
        medico: medico,
        especialidad: especialidad,
        fecha: fecha,
        horaInicio: horaInicio,
        motivo: motivo,
      );
      _citas.add(nuevaCita);
      notifyListeners();
      return true;
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
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
      final citaActualizada = await _citasRepository.cancelarCita(
        token: _token!,
        idCita: idCita,
        rowVersion: cita.rowVersion,
      );
      _citas[index] = citaActualizada;
      notifyListeners();
      return true;
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> atenderCita(int idCita, String notaMedica) async {
    final index = _citas.indexWhere((c) => c.idCita == idCita);
    if (index == -1) return false;

    final cita = _citas[index];
    if (_token == null) {
      throw AuthException('Debe iniciar sesión para atender una cita.');
    }

    try {
      final citaActualizada = await _citasRepository.atenderCita(
        token: _token!,
        idCita: idCita,
        notaMedica: notaMedica,
        rowVersion: cita.rowVersion,
      );
      _citas[index] = citaActualizada;
      notifyListeners();
      return true;
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
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

  Future<Paciente?> fetchPacientePerfil(int id) async {
    if (_token == null) return null;
    return await _pacientesRepository.fetchPacientePerfil(_token!, id);
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
    try {
      final ok = await _pacientesRepository.actualizarPacientePerfil(
        token: _token!,
        id: id,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
      );
      if (ok) {
        _currentUserName = '${nombre.trim()} ${apellido.trim()}';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<String> enviarMensajeChat(String mensaje, List<ChatMessage> historial) async {
    if (_token == null) {
      throw AuthException('Debe iniciar sesión para usar el chat.');
    }
    return await _chatRepository.enviarMensaje(
      token: _token!,
      mensaje: mensaje,
      historial: historial,
    );
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
