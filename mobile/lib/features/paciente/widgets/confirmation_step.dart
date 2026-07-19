import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../shared/models.dart';

class ConfirmationStep extends StatelessWidget {
  final Especialidad selectedSpecialty;
  final Medico selectedDoctor;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final String reasonText;

  const ConfirmationStep({
    super.key,
    required this.selectedSpecialty,
    required this.selectedDoctor,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.reasonText,
  });

  String _calculateEndTime(String start) {
    final parts = start.split(':');
    final hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    
    var endMin = min + 30;
    var endHour = hour;
    if (endMin >= 60) {
      endMin = 0;
      endHour = hour + 1;
    }
    return '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }

  Widget _buildConfirmRow(IconData icon, String label, String value, {bool isMultilines = false}) {
    return Row(
      crossAxisAlignment: isMultilines ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es').format(selectedDate);
    final displayedReason = reasonText.trim().isEmpty ? 'Consulta General' : reasonText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Resumen de tu Reserva',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Por favor verifica los detalles antes de confirmar.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Ticket layout card
        Card(
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      selectedSpecialty.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Body Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildConfirmRow(Icons.person_outline_rounded, 'Médico', selectedDoctor.nombreCompleto),
                    const Divider(height: 24),
                    _buildConfirmRow(Icons.calendar_today_rounded, 'Fecha', formattedDate),
                    const Divider(height: 24),
                    _buildConfirmRow(Icons.access_time_rounded, 'Horario', '$selectedTimeSlot - ${_calculateEndTime(selectedTimeSlot)}'),
                    const Divider(height: 24),
                    _buildConfirmRow(Icons.description_outlined, 'Motivo', displayedReason, isMultilines: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Reminder Alert Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recuerda que solo podrás cancelar o reagendar esta cita de forma autónoma con más de 24 horas de anticipación.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
