import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import 'widgets/agenda/agenda_header.dart';
import 'widgets/agenda/tarjeta_consulta.dart';
import 'widgets/agenda/tarjeta_disponible.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  late DateTime _selectedDay;
  late DateTime _focusedWeekMonday;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
    
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    // Adjust to Monday of current week
    _focusedWeekMonday = todayOnly.subtract(Duration(days: todayOnly.weekday - 1));
    _weekDays = List.generate(5, (index) => _focusedWeekMonday.add(Duration(days: index)));
    
    // Set selected day: if today is weekend (Sat/Sun), default to Monday of current week
    if (todayOnly.weekday == DateTime.saturday || todayOnly.weekday == DateTime.sunday) {
      _selectedDay = _focusedWeekMonday;
    } else {
      _selectedDay = todayOnly;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = AppStateProvider.of(context);
      appState.fetchCitas();
    });
  }

  void _updateWeek(DateTime monday) {
    setState(() {
      _focusedWeekMonday = monday;
      _weekDays = List.generate(5, (index) => monday.add(Duration(days: index)));
    });
  }

  void _goToPreviousWeek() {
    final prevMonday = _focusedWeekMonday.subtract(const Duration(days: 7));
    _updateWeek(prevMonday);
    final dayOffset = _selectedDay.weekday - 1;
    final targetDayIndex = (dayOffset >= 0 && dayOffset < 5) ? dayOffset : 0;
    setState(() {
      _selectedDay = prevMonday.add(Duration(days: targetDayIndex));
    });
  }

  void _goToNextWeek() {
    final nextMonday = _focusedWeekMonday.add(const Duration(days: 7));
    _updateWeek(nextMonday);
    final dayOffset = _selectedDay.weekday - 1;
    final targetDayIndex = (dayOffset >= 0 && dayOffset < 5) ? dayOffset : 0;
    setState(() {
      _selectedDay = nextMonday.add(Duration(days: targetDayIndex));
    });
  }

  void _goToToday() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final monday = todayOnly.subtract(Duration(days: todayOnly.weekday - 1));
    _updateWeek(monday);
    setState(() {
      if (todayOnly.weekday == DateTime.saturday || todayOnly.weekday == DateTime.sunday) {
        _selectedDay = monday;
      } else {
        _selectedDay = todayOnly;
      }
    });
  }

  Future<void> _selectDateFromPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      selectableDayPredicate: (DateTime val) {
        // Disable Saturday and Sunday in date picker since doctors don't work weekends
        return val.weekday != DateTime.saturday && val.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final pickedOnly = DateTime(picked.year, picked.month, picked.day);
      final monday = pickedOnly.subtract(Duration(days: pickedOnly.weekday - 1));
      _updateWeek(monday);
      setState(() {
        _selectedDay = pickedOnly;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

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
          // Agenda header widget with week controls & date picker
          AgendaHeader(
            focusedWeekMonday: _focusedWeekMonday,
            selectedDay: _selectedDay,
            weekDays: _weekDays,
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
              });
            },
            onPreviousWeek: _goToPreviousWeek,
            onNextWeek: _goToNextWeek,
            onGoToToday: _goToToday,
            onSelectDateFromPicker: _selectDateFromPicker,
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
