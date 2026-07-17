import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/models.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  late DateTime _selectedDay;
  late List<DateTime> _weekDays;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
    
    // Calculate current week days (Monday to Friday)
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    // Adjust to Monday
    final monday = todayOnly.subtract(Duration(days: todayOnly.weekday - 1));
    
    _weekDays = List.generate(5, (index) => monday.add(Duration(days: index)));
    
    // Set selected day. If today is weekend, default to Monday
    if (todayOnly.weekday == DateTime.saturday || todayOnly.weekday == DateTime.sunday) {
      _selectedDay = monday;
    } else {
      _selectedDay = todayOnly;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showAtenderDialog(BuildContext context, AppState appState, Cita cita) {
    _notesController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.rate_review_outlined, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Atender: ${cita.nombrePaciente}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motivo de consulta: "${cita.motivoConsulta}"',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notas Médicas y Diagnóstico',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Escriba aquí los síntomas, diagnóstico, prescripción médica o notas...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final notes = _notesController.text.trim();
              if (notes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, ingrese las notas médicas antes de completar.'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }
              
              appState.atenderCita(cita.idCita, notes);
              Navigator.pop(context); // Dismiss dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Consulta registrada como Atendida.'),
                  backgroundColor: AppTheme.secondary,
                ),
              );
            },
            child: const Text('Guardar y Completar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);

    // Filter appointments for the selected day
    final dayCitas = appState.citas.where((c) {
      return c.fecha.year == _selectedDay.year &&
             c.fecha.month == _selectedDay.month &&
             c.fecha.day == _selectedDay.day;
    }).toList();

    // Timeline base slots
    final baseSlots = [
      '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
      '16:00', '16:30', '17:00', '17:30'
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Weekly day selector header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _weekDays.map((day) {
                    final isSelected = day.year == _selectedDay.year &&
                                       day.month == _selectedDay.month &&
                                       day.day == _selectedDay.day;
                    final dayName = DateFormat('EEE', 'es').format(day).replaceAll('.', '');
                    final dayNum = DateFormat('d').format(day);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primary : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dayNum,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  DateFormat("EEEE, d 'de' MMMM", 'es').format(_selectedDay),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Timeline Slots list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: baseSlots.length,
              itemBuilder: (context, index) {
                final slot = baseSlots[index];
                
                // Check if doctor has an appointment starting in this slot
                final appointmentIndex = dayCitas.indexWhere((c) => c.horaInicio == slot && c.estado != 'Cancelada');
                
                if (appointmentIndex != -1) {
                  final cita = dayCitas[appointmentIndex];
                  return _buildAppointmentTile(context, appState, cita);
                } else {
                  return _buildEmptyTile(slot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(BuildContext context, AppState appState, Cita cita) {
    final isAttended = cita.estado == 'Atendida';
    final accentColor = isAttended ? AppTheme.secondary : AppTheme.primary;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: accentColor, width: 5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row with Time Slot & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${cita.horaInicio} - ${cita.horaFin}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isAttended ? const Color(0xFFE6F7F0) : AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    cita.estado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Patient Name
            Text(
              cita.nombrePaciente,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            
            // Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Motivo: ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textSecondary),
                ),
                Expanded(
                  child: Text(
                    cita.motivoConsulta,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            
            // Medical Notes (if attended)
            if (isAttended && cita.notaMedica != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Text(
                'Notas Médicas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.secondary),
              ),
              const SizedBox(height: 4),
              Text(
                cita.notaMedica!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
            
            // Action Button (if programada)
            if (!isAttended) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showAtenderDialog(context, appState, cita),
                icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
                label: const Text('Atender Consulta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTile(String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
