import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/models.dart';
import 'widgets/mis_citas/tarjeta_cita.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = AppStateProvider.of(context);
      appState.fetchCitas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return RefreshIndicator(
      onRefresh: () => appState.fetchCitas(),
      child: list.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
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
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final cita = list[index];
                return TarjetaCita(cita: cita);
              },
            ),
    );
  }
}
