import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../shared/models.dart';

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
        return _buildSpecialtyStep(appState);
      case 1:
        return _buildDoctorStep(appState);
      case 2:
        return _buildDateTimeStep(appState);
      case 3:
        return _buildReasonStep();
      case 4:
        return _buildConfirmationStep();
      default:
        return const SizedBox();
    }
  }

  // --- Step 1: Specialty ---
  Widget _buildSpecialtyStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Selecciona la Especialidad',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Elige el tipo de consulta médica que necesitas realizar.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...appState.especialidades.map((spec) {
          final isSelected = _selectedSpecialty?.idEspecialidad == spec.idEspecialidad;
          return Card(
            elevation: isSelected ? 4 : 1,
            color: isSelected ? AppTheme.primaryLight : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  if (_selectedSpecialty?.idEspecialidad != spec.idEspecialidad) {
                    _selectedSpecialty = spec;
                    _selectedDoctor = null; // Reset doctor selection
                    _selectedTimeSlot = null; // Reset slot
                  }
                });
                _nextStep(); // Auto-advance to next step
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSpecialtyIcon(spec.nombre),
                        color: AppTheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spec.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (spec.descripcion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              spec.descripcion!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  IconData _getSpecialtyIcon(String name) {
    switch (name.toLowerCase()) {
      case 'medicina general':
        return Icons.medication_rounded;
      case 'pediatría':
        return Icons.child_care_rounded;
      case 'cardiología':
        return Icons.favorite_rounded;
      case 'dermatología':
        return Icons.clean_hands_rounded;
      case 'odontología':
        return Icons.medical_services_rounded; // Actually dental_clinic or simple icons
      default:
        return Icons.healing_rounded;
    }
  }

  // --- Step 2: Doctor ---
  Widget _buildDoctorStep(AppState appState) {
    final filteredDoctors = appState.medicos
        .where((doc) => doc.idEspecialidad == _selectedSpecialty?.idEspecialidad && doc.activo)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_right_rounded, color: AppTheme.primary),
            Text(
              'Especialidad: ${_selectedSpecialty?.nombre}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Selecciona al Médico',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Elige uno de nuestros médicos calificados para tu atención.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 16),
        if (filteredDoctors.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'No hay médicos disponibles para esta especialidad en este momento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
            ),
          )
        else
          ...filteredDoctors.map((doc) {
            final isSelected = _selectedDoctor?.idMedico == doc.idMedico;
            return Card(
              elevation: isSelected ? 4 : 1,
              color: isSelected ? AppTheme.primaryLight : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    if (_selectedDoctor?.idMedico != doc.idMedico) {
                      _selectedDoctor = doc;
                      _selectedTimeSlot = null; // Reset slot
                    }
                  });
                  _nextStep();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child: Text(
                          doc.nombre[0] + doc.apellido[0],
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.nombreCompleto,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc.correo,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            if (doc.telefono != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Tel: ${doc.telefono}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                        color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  // --- Step 3: Date & Time ---
  Widget _buildDateTimeStep(AppState appState) {
    if (_selectedDoctor == null) return const SizedBox();
    
    final slots = appState.getAvailableSlots(_selectedDoctor!, _selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_right_rounded, color: AppTheme.primary),
            Text(
              'Médico: ${_selectedDoctor!.nombreCompleto}',
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
          onTap: () => _selectDate(context),
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
                  DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es').format(_selectedDate),
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
        if (slots.isEmpty)
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
                  _selectedDate.weekday == DateTime.saturday || _selectedDate.weekday == DateTime.sunday
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
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final isSelected = _selectedTimeSlot == slot;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                },
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

  // --- Step 4: Reason ---
  Widget _buildReasonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Motivo de la Consulta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        const Text(
          'Describe brevemente la razón de tu cita. Esto ayuda al médico a prepararse mejor.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reasonController,
          maxLines: 5,
          maxLength: 255,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Ej. Dolor persistente de cabeza durante los últimos dos días, chequeo de seguimiento...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // --- Step 5: Confirmation ---
  Widget _buildConfirmationStep() {
    final formattedDate = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es').format(_selectedDate);
    final reasonText = _reasonController.text.trim().isEmpty 
        ? 'Consulta General' 
        : _reasonController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Resumen de tu Reserva',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Por favor verifica los detalles antes de confirmar.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Ticket layout card
        Card(
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital_rounded, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      _selectedSpecialty?.nombre ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Body Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildConfirmRow(Icons.person_outline_rounded, 'Médico', _selectedDoctor?.nombreCompleto ?? ''),
                    const Divider(height: 24),
                    _buildConfirmRow(Icons.calendar_today_rounded, 'Fecha', formattedDate),
                    const Divider(height: 24),
                    _buildConfirmRow(Icons.access_time_rounded, 'Horario', '$_selectedTimeSlot - ${_calculateEndTime(_selectedTimeSlot!)}'),
                    const Divider(height: 24),
                    _buildConfirmRow(Icons.description_outlined, 'Motivo', reasonText, isMultilines: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Reminder Alert Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recuerda que solo podrás cancelar o reagendar esta cita de forma autónoma con más de 24 horas de anticipación.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateEndTime(String start) {
    final parts = start.split(':');
    final hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    
    var endMin = min + 30;
    var endHour = hour;
    if (endMin >= 60) {
      endMin = 0;
      endHour = hour + 1;
    }
    return '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }

  Widget _buildConfirmRow(IconData icon, String label, String value, {bool isMultilines = false}) {
    return Row(
      crossAxisAlignment: isMultilines ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
