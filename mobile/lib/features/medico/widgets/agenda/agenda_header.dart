import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';

class AgendaHeader extends StatelessWidget {
  final DateTime focusedWeekMonday;
  final DateTime selectedDay;
  final List<DateTime> weekDays;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onGoToToday;
  final VoidCallback onSelectDateFromPicker;

  const AgendaHeader({
    super.key,
    required this.focusedWeekMonday,
    required this.selectedDay,
    required this.weekDays,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onGoToToday,
    required this.onSelectDateFromPicker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthYearStr = DateFormat("MMMM yyyy", 'es').format(focusedWeekMonday);
    final capitalizedMonthYear = monthYearStr.isNotEmpty
        ? monthYearStr[0].toUpperCase() + monthYearStr.substring(1)
        : monthYearStr;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          // Top control bar: Month/Year, Today, Calendar Picker, Prev/Next Week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                capitalizedMonthYear,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: onGoToToday,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.today, size: 16, color: AppTheme.primary),
                          SizedBox(width: 4),
                          Text(
                            'Hoy',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, size: 20),
                    color: AppTheme.primary,
                    tooltip: 'Seleccionar fecha',
                    onPressed: onSelectDateFromPicker,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 24),
                    color: AppTheme.textPrimary,
                    tooltip: 'Semana anterior',
                    onPressed: onPreviousWeek,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 24),
                    color: AppTheme.textPrimary,
                    tooltip: 'Semana siguiente',
                    onPressed: onNextWeek,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Days row (5 working days: Mon to Fri)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day) {
              final isSelected = day.year == selectedDay.year &&
                  day.month == selectedDay.month &&
                  day.day == selectedDay.day;
              final isToday = day.year == todayOnly.year &&
                  day.month == todayOnly.month &&
                  day.day == todayOnly.day;

              final dayName = DateFormat('EEE', 'es').format(day).replaceAll('.', '');
              final dayNum = DateFormat('d').format(day);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () => onDaySelected(day),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : isToday
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : isToday
                                  ? AppTheme.primary
                                  : Colors.grey.shade200,
                          width: isToday && !isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white70
                                  : isToday
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayNum,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
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
            DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es').format(selectedDay),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
