import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/models.dart';
import 'widgets/specialty_step.dart';
import 'widgets/doctor_step.dart';
import 'widgets/date_time_step.dart';
import 'widgets/reason_step.dart';
import 'widgets/confirmation_step.dart';

class ReservarCitaView extends StatefulWidget {
  final VoidCallback onBookingSuccess;

  const ReservarCitaView({super.key, required this.onBookingSuccess});

  @override
  State<ReservarCitaView> createState() => ReservarCitaViewState();
}

class ReservarCitaViewState extends State<ReservarCitaView> {
  int _currentStep = 0;
  
  // Selection state
  Especialidad? _selectedSpecialty;
  Medico? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default to tomorrow
  String? _selectedTimeSlot;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = AppStateProvider.of(context);
      if (appState.especialidades.isEmpty) {
        appState.fetchEspecialidades().catchError((error) {
          debugPrint('Error en precarga de especialidades: $error');
        });
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void resetStepper() {
    setState(() {
      _currentStep = 0;
      _selectedSpecialty = null;
      _selectedDoctor = null;
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTimeSlot = null;
      _reasonController.clear();
    });
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(DateTime.now()) ? DateTime.now().add(const Duration(days: 1)) : _selectedDate,
      firstDate: DateTime.now(), // Can't book past dates
      lastDate: DateTime.now().add(const Duration(days: 30)), // 30 days window
      selectableDayPredicate: (date) {
        // Exclude weekends (Lunes a Viernes only)
        return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot when date changes
      });
    }
  }

  void _confirmBooking() {
    if (_selectedDoctor == null || _selectedSpecialty == null || _selectedTimeSlot == null) {
      return;
    }

    final appState = AppStateProvider.of(context);
    appState.reservarCita(
      medico: _selectedDoctor!,
      especialidad: _selectedSpecialty!,
      fecha: _selectedDate,
      horaInicio: _selectedTimeSlot!,
      motivo: _reasonController.text.trim().isEmpty ? 'Consulta General' : _reasonController.text.trim(),
    );

    // Show Success Dialog / Animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.secondary,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Cita Reservada!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu cita ha sido programada exitosamente. Puedes revisarla y gestionarla en la sección de Mis Citas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Dismiss dialog
                  resetStepper();
                  widget.onBookingSuccess(); // Navigate to tab 1
                },
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);

    // Calculate progress indicator
    final stepsHeaders = ['Especialidad', 'Médico', 'Fecha/Hora', 'Motivo', 'Confirmación'];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Custom Progress Bar at the top
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final isActive = index <= _currentStep;
                    final isCurrent = index == _currentStep;
                    return Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppTheme.primary
                                  : isActive
                                      ? AppTheme.primary.withOpacity(0.7)
                                      : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          if (index < 4)
                            Expanded(
                              child: Container(
                                height: 3,
                                color: index < _currentStep
                                    ? AppTheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  stepsHeaders[_currentStep],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Step Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(appState),
            ),
          ),

          // Bottom Navigation Buttons (Back & Next/Confirm)
          if (_currentStep > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primary),
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('Atrás'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isNextStepEnabled()
                          ? (_currentStep == 4 ? _confirmBooking : _nextStep)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_currentStep == 4 ? 'Confirmar Cita' : 'Continuar'),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 4 ? Icons.done_all : Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isNextStepEnabled() {
    switch (_currentStep) {
      case 0:
        return _selectedSpecialty != null;
      case 1:
        return _selectedDoctor != null;
      case 2:
        return _selectedTimeSlot != null;
      case 3:
        return true; // Motif can be optional/filled later
      case 4:
        return true; // Already verified
      default:
        return false;
    }
  }

  Widget _buildStepContent(AppState appState) {
    switch (_currentStep) {
      case 0:
        return SpecialtyStep(
          especialidades: appState.especialidades,
          selectedSpecialty: _selectedSpecialty,
          onSpecialtySelected: (spec) {
            setState(() {
              if (_selectedSpecialty?.idEspecialidad != spec.idEspecialidad) {
                _selectedSpecialty = spec;
                _selectedDoctor = null; // Reset doctor selection
                _selectedTimeSlot = null; // Reset slot
              }
            });
            _nextStep(); // Auto-advance to next step
          },
        );
      case 1:
        final filteredDoctors = appState.medicos
            .where((doc) => doc.idEspecialidad == _selectedSpecialty?.idEspecialidad && doc.activo)
            .toList();
        return DoctorStep(
          filteredDoctors: filteredDoctors,
          selectedSpecialty: _selectedSpecialty!,
          selectedDoctor: _selectedDoctor,
          onDoctorSelected: (doc) {
            setState(() {
              if (_selectedDoctor?.idMedico != doc.idMedico) {
                _selectedDoctor = doc;
                _selectedTimeSlot = null; // Reset slot
              }
            });
            _nextStep();
          },
        );
      case 2:
        final slots = appState.getAvailableSlots(_selectedDoctor!, _selectedDate);
        return DateTimeStep(
          selectedDoctor: _selectedDoctor!,
          selectedDate: _selectedDate,
          selectedTimeSlot: _selectedTimeSlot,
          availableSlots: slots,
          onSelectDate: () => _selectDate(context),
          onTimeSlotSelected: (slot) {
            setState(() {
              _selectedTimeSlot = slot;
            });
          },
        );
      case 3:
        return ReasonStep(
          reasonController: _reasonController,
        );
      case 4:
        return ConfirmationStep(
          selectedSpecialty: _selectedSpecialty!,
          selectedDoctor: _selectedDoctor!,
          selectedDate: _selectedDate,
          selectedTimeSlot: _selectedTimeSlot!,
          reasonText: _reasonController.text,
        );
      default:
        return const SizedBox();
    }
  }
}
