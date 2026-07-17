import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import 'mis_citas_view.dart';
import 'reservar_cita_view.dart';

class PacienteHomeScreen extends StatefulWidget {
  const PacienteHomeScreen({super.key});

  @override
  State<PacienteHomeScreen> createState() => _PacienteHomeScreenState();
}

class _PacienteHomeScreenState extends State<PacienteHomeScreen> {
  int _currentIndex = 0;

  // Let's hold the stateful sub-views. ReservarCitaView needs a key so we can reset it when they switch pages or confirm a booking.
  final GlobalKey<ReservarCitaViewState> _reservarCitaKey = GlobalKey<ReservarCitaViewState>();

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    
    final List<Widget> views = [
      ReservarCitaView(
        key: _reservarCitaKey,
        onBookingSuccess: () {
          // Switch to "Mis Citas" tab on successful reservation
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const MisCitasView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Portal del Paciente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            Text(
              'Hola, ${appState.currentUserName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // Confirmation Dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Está seguro de que desea salir del portal?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Dismiss dialog
                        appState.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // If they click on Reservar Cita, reset its stepper state
            if (index == 0) {
              _reservarCitaKey.currentState?.resetStepper();
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Reservar Cita',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Mis Citas',
            ),
          ],
        ),
      ),
    );
  }
}
