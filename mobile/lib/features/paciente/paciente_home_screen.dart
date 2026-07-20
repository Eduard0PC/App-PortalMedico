import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/widgets/editar_perfil_modal.dart';
import 'mis_citas_view.dart';
import 'reservar_cita_view.dart';

class PacienteHomeScreen extends StatefulWidget {
  const PacienteHomeScreen({super.key});

  @override
  State<PacienteHomeScreen> createState() => _PacienteHomeScreenState();
}

class _PacienteHomeScreenState extends State<PacienteHomeScreen> {
  int _currentIndex = 0;

  // Key to reset stepper state when switching tabs
  final GlobalKey<ReservarCitaViewState> _reservarCitaKey = GlobalKey<ReservarCitaViewState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = AppStateProvider.of(context);
      appState.fetchCitas();
      appState.fetchEspecialidades();
    });
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'P';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'P';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final userName = appState.currentUserName;
    final initials = _getInitials(userName);

    final List<Widget> views = [
      ReservarCitaView(
        key: _reservarCitaKey,
        onBookingSuccess: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const MisCitasView(),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            // User Avatar Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // User Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PORTAL DEL PACIENTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '¡Hola, ${userName.split(' ').first}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Edit Profile Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => EditarPerfilModal.mostrar(context),
              child: Tooltip(
                message: 'Editar Perfil',
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Logout Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('Cerrar Sesión'),
                      ],
                    ),
                    content: const Text(
                      '¿Está seguro de que desea salir del portal del paciente?',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          appState.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Salir', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                );
              },
              child: Tooltip(
                message: 'Cerrar Sesión',
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.error,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: AppTheme.textSecondary,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                if (index == 0) {
                  _reservarCitaKey.currentState?.resetStepper();
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _currentIndex == 0 ? AppTheme.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add_circle_rounded, color: AppTheme.primary),
                  ),
                  label: 'Reservar Cita',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _currentIndex == 1 ? AppTheme.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.calendar_month_outlined),
                  ),
                  activeIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                  ),
                  label: 'Mis Citas',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
