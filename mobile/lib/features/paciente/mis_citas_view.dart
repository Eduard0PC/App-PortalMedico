import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/models.dart';

class MisCitasView extends StatefulWidget {
  const MisCitasView({super.key});

  @override
  State<MisCitasView> createState() => _MisCitasViewState();
}

class _MisCitasViewState extends State<MisCitasView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize date formatting in Spanish
    initializeDateFormatting('es', null);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleCancelCita(BuildContext context, AppState appState, Cita cita) {
    if (cita.esCancelable) {
      // Confimation Dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.accent),
              SizedBox(width: 8),
              Text('Cancelar Cita'),
            ],
          ),
          content: Text(
            '¿Está seguro de que desea cancelar su cita con el ${cita.medico.nombreCompleto} programada para el ${DateFormat('dd/MM/yyyy').format(cita.fecha)} a las ${cita.horaInicio}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, conservar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss dialog
                final success = appState.cancelarCita(cita.idCita);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cita cancelada con éxito.'),
                      backgroundColor: AppTheme.secondary,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text('Sí, cancelar'),
            ),
          ],
        ),
      );
    } else {
      // Rule violation dialog: Less than 24 hours
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppTheme.error),
              SizedBox(width: 8),
              Text('Atención'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No es posible cancelar la cita.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'De acuerdo con las políticas de la clínica, las citas solo pueden ser canceladas desde la aplicación con al menos 24 horas de anticipación.',
              ),
              SizedBox(height: 12),
              Text(
                'Para cancelar o reagendar esta cita, comuníquese directamente con la clínica:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_rounded, color: AppTheme.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '+1 555-0100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    // Split appointments
    final today = DateTime.now();
    final todayOnlyDate = DateTime(today.year, today.month, today.day);
    
    // Upcoming: Programada and (date >= today or date is today but slot time is in the future)
    final upcomingCitas = appState.citas.where((cita) {
      if (cita.estado != 'Programada') return false;
      if (cita.fecha.isAfter(todayOnlyDate)) return true;
      
      if (cita.fecha.year == todayOnlyDate.year &&
          cita.fecha.month == todayOnlyDate.month &&
          cita.fecha.day == todayOnlyDate.day) {
        // Check slot time
        final parts = cita.horaInicio.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final min = int.tryParse(parts[1]) ?? 0;
        final citaTime = DateTime(today.year, today.month, today.day, hour, min);
        return citaTime.isAfter(today);
      }
      return false;
    }).toList();

    // History: Atendida, Cancelada, or past Programada appointments
    final historyCitas = appState.citas.where((cita) {
      return !upcomingCitas.contains(cita);
    }).toList();

    return Column(
      children: [
        // TabBar Header
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            indicatorWeight: 3,
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upcoming_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Próximas'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Historial'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // TabBar Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCitasList(upcomingCitas, appState, isUpcoming: true),
              _buildCitasList(historyCitas, appState, isUpcoming: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCitasList(List<Cita> list, AppState appState, {required bool isUpcoming}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUpcoming ? Icons.calendar_today_outlined : Icons.folder_off_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                isUpcoming ? 'No tienes citas programadas' : 'No hay historial de citas',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                isUpcoming
                    ? '¿Necesitas ver a un médico? Reserva una nueva cita en la pestaña correspondiente.'
                    : 'Aquí aparecerán las citas que hayan sido atendidas o canceladas.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final cita = list[index];
        return _buildCitaCard(cita, appState);
      },
    );
  }

  Widget _buildCitaCard(Cita cita, AppState appState) {
    final formattedDate = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es').format(cita.fecha);
    
    // Status Badge Configuration
    Color badgeColor;
    Color badgeTextColor;
    String statusLabel = cita.estado;

    switch (cita.estado) {
      case 'Programada':
        badgeColor = AppTheme.primaryLight;
        badgeTextColor = AppTheme.primary;
        statusLabel = 'Programada';
        break;
      case 'Atendida':
        badgeColor = const Color(0xFFE6F7F0);
        badgeTextColor = AppTheme.secondary;
        statusLabel = 'Atendida';
        break;
      case 'Cancelada':
        badgeColor = const Color(0xFFFDE8E8);
        badgeTextColor = AppTheme.error;
        statusLabel = cita.canceladaPor != null ? 'Cancelada (${cita.canceladaPor})' : 'Cancelada';
        break;
      default:
        badgeColor = Colors.grey.shade100;
        badgeTextColor = AppTheme.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // Colored side border based on state
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        title: Row(
          children: [
            Expanded(
              child: Text(
                cita.medico.nombreCompleto,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              cita.especialidad.nombre,
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${cita.horaInicio} - ${cita.horaFin}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ],
        ),
        children: [
          // Divider
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // Reason for Consultation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined, color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Motivo de Consulta',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cita.motivoConsulta,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Medical Notes (if present)
          if (cita.notaMedica != null && cita.notaMedica!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.rate_review_outlined, color: AppTheme.secondary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notas Médicas',
                        style: TextStyle(fontSize: 11, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryLight),
                        ),
                        child: Text(
                          cita.notaMedica!,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Action Buttons: Only show "Cancelar" if Programada
          if (cita.estado == 'Programada') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleCancelCita(context, appState, cita),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancelar Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
