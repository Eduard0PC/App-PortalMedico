import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import 'widgets/agenda/tarjeta_consulta.dart';
import 'widgets/agenda/tarjeta_disponible.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  late DateTime _selectedDay;
  late List<DateTime> _weekDays;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = AppStateProvider.of(context);
      appState.fetchCitas();
    });
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
            child: RefreshIndicator(
              onRefresh: () => appState.fetchCitas(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: baseSlots.length,
                itemBuilder: (context, index) {
                  final slot = baseSlots[index];
                  
                  // Check if doctor has an appointment starting in this slot
                  final appointmentIndex = dayCitas.indexWhere((c) => c.horaInicio == slot && c.estado != 'Cancelada');
                  
                  if (appointmentIndex != -1) {
                    final cita = dayCitas[appointmentIndex];
                    return TarjetaConsulta(cita: cita);
                  } else {
                    return TarjetaDisponible(time: slot);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
