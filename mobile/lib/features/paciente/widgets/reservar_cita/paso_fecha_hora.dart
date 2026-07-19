import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models.dart';

class PasoFechaHora extends StatelessWidget {
  final Medico selectedDoctor;
  final DateTime selectedDate;
  final String? selectedTimeSlot;
  final List<String> availableSlots;
  final VoidCallback onSelectDate;
  final ValueChanged<String> onTimeSlotSelected;

  const PasoFechaHora({
    super.key,
    required this.selectedDoctor,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.availableSlots,
    required this.onSelectDate,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_right_rounded, color: AppTheme.primary),
            Text(
              'Médico: ${selectedDoctor.nombreCompleto}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Date Selection Row
        const Text(
          'Selecciona la Fecha',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onSelectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                const SizedBox(width: 12),
                Text(
                  DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.edit_calendar_rounded, color: AppTheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Time Slots Grid
        const Text(
          'Horas Disponibles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bloques de consulta de 30 minutos (Horario de atención: 8:00 AM - 6:00 PM).',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        if (availableSlots.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.error.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.error, size: 28),
                const SizedBox(height: 8),
                Text(
                  selectedDate.weekday == DateTime.saturday || selectedDate.weekday == DateTime.sunday
                      ? 'Los fines de semana no hay atención. Por favor selecciona un día hábil (Lunes a Viernes).'
                      : 'No quedan horarios disponibles para este día. Por favor elige otra fecha.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final slot = availableSlots[index];
              final isSelected = selectedTimeSlot == slot;
              return InkWell(
                onTap: () => onTimeSlotSelected(slot),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
