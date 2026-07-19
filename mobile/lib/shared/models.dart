class Especialidad {
  final int idEspecialidad;
  final String nombre;
  final String? descripcion;

  const Especialidad({
    required this.idEspecialidad,
    required this.nombre,
    this.descripcion,
  });

  factory Especialidad.fromJson(Map<String, dynamic> json) {
    return Especialidad(
      idEspecialidad: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
    );
  }
}

class Paciente {
  final int idPaciente;
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono;
  final DateTime? fechaNacimiento;
  final DateTime? fechaCreacion;

  const Paciente({
    required this.idPaciente,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono,
    this.fechaNacimiento,
    this.fechaCreacion,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Paciente.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      final str = raw.toString();
      return DateTime.tryParse(str);
    }

    return Paciente(
      idPaciente: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      telefono: json['telefono'] as String?,
      fechaNacimiento: parseDate(json['fechaNacimiento']),
      fechaCreacion: parseDate(json['fechaCreacion']),
    );
  }
}

class Medico {
  final int idMedico;
  final String nombre;
  final String apellido;
  final String correo;
  final int idEspecialidad;
  final String? nombreEspecialidad;
  final String? telefono;
  final bool activo;

  const Medico({
    required this.idMedico,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.idEspecialidad,
    this.nombreEspecialidad,
    this.telefono,
    this.activo = true,
  });

  String get nombreCompleto => 'Dr. $nombre $apellido';

  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      idMedico: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      idEspecialidad: (json['idEspecialidad'] as num?)?.toInt() ?? 0,
      nombreEspecialidad: json['nombreEspecialidad'] as String?,
      telefono: json['telefono'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }
}

class Cita {
  final int idCita;
  final int idPaciente;
  final String nombrePaciente;
  final Medico medico;
  final Especialidad especialidad;
  final DateTime fecha; // Solo dia
  final String horaInicio; // Ej: "08:30"
  final String horaFin; // Ej: "09:00"
  final String motivoConsulta;
  final String estado; // 'Programada', 'Atendida', 'Cancelada'
  final String? notaMedica;
  final String? canceladaPor; // 'Paciente', 'Administrador'
  final int rowVersion;

  const Cita({
    required this.idCita,
    required this.idPaciente,
    required this.nombrePaciente,
    required this.medico,
    required this.especialidad,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.motivoConsulta,
    required this.estado,
    this.notaMedica,
    this.canceladaPor,
    this.rowVersion = 0,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    final fechaRaw = json['fecha'] as String? ?? DateTime.now().toIso8601String();
    final fechaParsed = DateTime.tryParse(fechaRaw) ?? DateTime.now();

    String parseHora(dynamic raw) {
      if (raw == null) return '00:00';
      final str = raw.toString();
      final parts = str.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return str;
    }

    final horaInicioFormatted = parseHora(json['horaInicio']);
    final horaFinFormatted = parseHora(json['horaFin']);

    final nombreMedicoStr = json['nombreMedico'] as String? ?? 'Médico';
    final nameParts = nombreMedicoStr.trim().split(' ');
    final medNombre = nameParts.isNotEmpty ? nameParts.first : 'Médico';
    final medApellido = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final medicoObj = Medico(
      idMedico: (json['idMedico'] as num?)?.toInt() ?? 0,
      nombre: medNombre,
      apellido: medApellido,
      correo: '',
      idEspecialidad: 0,
    );

    final especialidadObj = Especialidad(
      idEspecialidad: 0,
      nombre: json['nombreEspecialidad'] as String? ?? 'Especialidad',
    );

    return Cita(
      idCita: (json['id'] as num?)?.toInt() ?? 0,
      idPaciente: (json['idPaciente'] as num?)?.toInt() ?? 0,
      nombrePaciente: json['nombrePaciente'] as String? ?? 'Paciente',
      medico: medicoObj,
      especialidad: especialidadObj,
      fecha: DateTime(fechaParsed.year, fechaParsed.month, fechaParsed.day),
      horaInicio: horaInicioFormatted,
      horaFin: horaFinFormatted,
      motivoConsulta: json['motivoConsulta'] as String? ?? '',
      estado: json['estado'] as String? ?? 'Programada',
      notaMedica: json['notaMedica'] as String?,
      canceladaPor: json['canceladaPor'] as String?,
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 0,
    );
  }

  Cita copyWith({
    int? idCita,
    int? idPaciente,
    String? nombrePaciente,
    Medico? medico,
    Especialidad? especialidad,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    String? motivoConsulta,
    String? estado,
    String? notaMedica,
    String? canceladaPor,
    int? rowVersion,
  }) {
    return Cita(
      idCita: idCita ?? this.idCita,
      idPaciente: idPaciente ?? this.idPaciente,
      nombrePaciente: nombrePaciente ?? this.nombrePaciente,
      medico: medico ?? this.medico,
      especialidad: especialidad ?? this.especialidad,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      estado: estado ?? this.estado,
      notaMedica: notaMedica ?? this.notaMedica,
      canceladaPor: canceladaPor ?? this.canceladaPor,
      rowVersion: rowVersion ?? this.rowVersion,
    );
  }

  // Helper to check if appointment is cancellable (> 24 hours from now)
  bool get esCancelable {
    if (estado != 'Programada') return false;
    
    // Parse time components
    final parts = horaInicio.split(':');
    if (parts.length < 2) return false;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    final appointmentDateTime = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hours,
      minutes,
    );

    final difference = appointmentDateTime.difference(DateTime.now());
    return difference.inHours >= 24;
  }
}
