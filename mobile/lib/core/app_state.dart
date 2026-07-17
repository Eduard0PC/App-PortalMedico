import 'package:flutter/material.dart';
import '../shared/models.dart';

class AppState extends ChangeNotifier {
  // Current logged in user (null if guest)
  String? _currentUserEmail;
  String? _currentUserName;
  int? _currentUserId;
  String? _userRole; // 'Paciente' o 'Medico'

  bool get isLoggedIn => _currentUserEmail != null;
  String get currentUserName => _currentUserName ?? 'Paciente';
  int get currentUserId => _currentUserId ?? 1;
  String get currentUserEmail => _currentUserEmail ?? '';
  String get userRole => _userRole ?? 'Paciente';

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
    // 1. Specialties
    _especialidades.addAll([
      const Especialidad(
        idEspecialidad: 1,
        nombre: 'Medicina General',
        descripcion: 'Atención primaria y preventiva para toda la familia.',
      ),
      const Especialidad(
        idEspecialidad: 2,
        nombre: 'Pediatría',
        descripcion: 'Cuidado de la salud física y mental de niños y adolescentes.',
      ),
      const Especialidad(
        idEspecialidad: 3,
        nombre: 'Cardiología',
        descripcion: 'Diagnóstico y tratamiento de enfermedades cardiovasculares.',
      ),
      const Especialidad(
        idEspecialidad: 4,
        nombre: 'Dermatología',
        descripcion: 'Especialistas en la salud y enfermedades de la piel y cabello.',
      ),
      const Especialidad(
        idEspecialidad: 5,
        nombre: 'Odontología',
        descripcion: 'Cuidado y salud oral, limpiezas y ortodoncia.',
      ),
    ]);

    // 2. Medicos
    _medicos.addAll([
      // General Medicine (Dr. Carlos Garcia is the target doctor for doctor login demo)
      const Medico(
        idMedico: 101,
        nombre: 'Carlos',
        apellido: 'García',
        correo: 'carlos.garcia@clinica.com',
        idEspecialidad: 1,
        telefono: '555-0101',
      ),
      const Medico(
        idMedico: 102,
        nombre: 'María',
        apellido: 'Fernández',
        correo: 'maria.fernandez@clinica.com',
        idEspecialidad: 1,
        telefono: '555-0102',
      ),
      // Pediatría
      const Medico(
        idMedico: 201,
        nombre: 'Ana',
        apellido: 'Martínez',
        correo: 'ana.martinez@clinica.com',
        idEspecialidad: 2,
        telefono: '555-0201',
      ),
      const Medico(
        idMedico: 202,
        nombre: 'Luis',
        apellido: 'Torres',
        correo: 'luis.torres@clinica.com',
        idEspecialidad: 2,
        telefono: '555-0202',
      ),
      // Cardiología
      const Medico(
        idMedico: 301,
        nombre: 'Roberto',
        apellido: 'Sánchez',
        correo: 'roberto.sanchez@clinica.com',
        idEspecialidad: 3,
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
      especialidad: _especialidades[0],
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
      especialidad: _especialidades[1],
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
      especialidad: _especialidades[2],
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
      especialidad: _especialidades[0],
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
      especialidad: _especialidades[0],
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
      especialidad: _especialidades[0],
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
      especialidad: _especialidades[0],
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
      especialidad: _especialidades[0],
      fecha: friday,
      horaInicio: '16:00',
      horaFin: '16:30',
      motivoConsulta: 'Chequeo general preventivo.',
      estado: 'Programada',
    ));
  }

  // Authentication Actions
  bool login(String email, String password, {bool isDemo = false, String? demoRole}) {
    if (isDemo) {
      if (demoRole == 'Medico') {
        _currentUserEmail = 'carlos.garcia@clinica.com';
        _currentUserName = 'Carlos García';
        _currentUserId = 101; // Dr. Carlos García
        _userRole = 'Medico';
      } else {
        _currentUserEmail = 'paciente.demo@gmail.com';
        _currentUserName = 'Eduardo García';
        _currentUserId = 1;
        _userRole = 'Paciente';
      }
      notifyListeners();
      return true;
    }

    if (email.isNotEmpty && password.length >= 6) {
      final trimmedEmail = email.trim().toLowerCase();
      // Check if email corresponds to a doctor
      final doctorIndex = _medicos.indexWhere((doc) => doc.correo.toLowerCase() == trimmedEmail);
      if (doctorIndex != -1) {
        final doc = _medicos[doctorIndex];
        _currentUserEmail = doc.correo;
        _currentUserName = doc.nombreCompleto;
        _currentUserId = doc.idMedico;
        _userRole = 'Medico';
      } else {
        _currentUserEmail = email;
        // Extract name from email
        final namePart = email.split('@').first;
        _currentUserName = namePart.substring(0, 1).toUpperCase() + namePart.substring(1);
        _currentUserId = email.hashCode.abs();
        _userRole = 'Paciente';
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void register({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required DateTime? fechaNacimiento,
    required String password,
  }) {
    _currentUserEmail = correo;
    _currentUserName = '$nombre $apellido';
    _currentUserId = correo.hashCode.abs();
    _userRole = 'Paciente';
    notifyListeners();
  }

  void logout() {
    _currentUserEmail = null;
    _currentUserName = null;
    _currentUserId = null;
    _userRole = null;
    notifyListeners();
  }

  // Appointment Actions
  void reservarCita({
    required Medico medico,
    required Especialidad especialidad,
    required DateTime fecha,
    required String horaInicio,
    required String motivo,
  }) {
    // Calculate horaFin (horaInicio + 30 min)
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
  }

  bool cancelarCita(int idCita) {
    final index = _citas.indexWhere((c) => c.idCita == idCita);
    if (index != -1) {
      final cita = _citas[index];
      if (cita.esCancelable) {
        _citas[index] = cita.copyWith(
          estado: 'Cancelada',
          canceladaPor: 'Paciente',
        );
        notifyListeners();
        return true;
      }
    }
    return false;
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
