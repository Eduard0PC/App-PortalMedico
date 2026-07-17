class Especialidad {
  final int idEspecialidad;
  final String nombre;
  final String? descripcion;

  const Especialidad({
    required this.idEspecialidad,
    required this.nombre,
    this.descripcion,
  });
}

class Medico {
  final int idMedico;
  final String nombre;
  final String apellido;
  final String correo;
  final int idEspecialidad;
  final String? telefono;
  final bool activo;

  const Medico({
    required this.idMedico,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.idEspecialidad,
    this.telefono,
    this.activo = true,
  });

  String get nombreCompleto => 'Dr. $nombre $apellido';
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
  });

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
    );
  }

  // Helper to check if appointment is cancellable (> 24 hours from now)
  bool get esCancelable {
    if (estado != 'Programada') return false;
    
    // Parse time components
    final parts = horaInicio.split(':');
    if (parts.length != 2) return false;
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
