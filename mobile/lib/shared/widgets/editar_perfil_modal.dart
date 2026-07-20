import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';

class EditarPerfilModal extends StatefulWidget {
  const EditarPerfilModal({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditarPerfilModal(),
    );
  }

  @override
  State<EditarPerfilModal> createState() => _EditarPerfilModalState();
}

class _EditarPerfilModalState extends State<EditarPerfilModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;

  String _correo = '';
  DateTime? _fechaNacimiento;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _telefonoController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosPerfil();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosPerfil() async {
    final appState = AppStateProvider.of(context);

    try {
      final paciente = await appState.fetchPacientePerfil(appState.currentUserId);
      if (paciente != null) {
        _nombreController.text = paciente.nombre;
        _apellidoController.text = paciente.apellido;
        _telefonoController.text = paciente.telefono ?? '';
        _fechaNacimiento = paciente.fechaNacimiento;
        _correo = paciente.correo;
      } else {
        final parts = appState.currentUserName.trim().split(' ');
        _nombreController.text = parts.isNotEmpty ? parts.first : '';
        _apellidoController.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        _correo = appState.currentUserEmail;
      }
    } catch (e) {
      debugPrint('Error cargando perfil paciente: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final now = DateTime.now();
    final initial = _fechaNacimiento ?? DateTime(1995, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'SELECCIONAR FECHA DE NACIMIENTO',
      cancelText: 'CANCELAR',
      confirmText: 'SELECCIONAR',
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = AppStateProvider.of(context);

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await appState.actualizarPacientePerfil(
        id: appState.currentUserId,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        telefono: _telefonoController.text,
        fechaNacimiento: _fechaNacimiento,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Perfil actualizado correctamente.'),
              ],
            ),
            backgroundColor: AppTheme.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with Avatar & Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
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
                          'Editar Perfil',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        Text(
                          'Información personal del paciente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: AppTheme.error, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Read-only email field
                            TextFormField(
                              initialValue: _correo.isNotEmpty ? _correo : appState.currentUserEmail,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                                suffixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 18),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                helperText: 'El correo no se puede modificar desde el perfil.',
                                helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Nombre
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'El nombre es obligatorio.';
                                }
                                if (val.trim().length > 100) {
                                  return 'El nombre no puede exceder 100 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Apellido
                            TextFormField(
                              controller: _apellidoController,
                              decoration: const InputDecoration(
                                labelText: 'Apellido *',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'El apellido es obligatorio.';
                                }
                                if (val.trim().length > 100) {
                                  return 'El apellido no puede exceder 100 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Teléfono
                            TextFormField(
                              controller: _telefonoController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                prefixIcon: Icon(Icons.phone_outlined),
                                hintText: 'Ej: +504 9999-9999',
                              ),
                              validator: (val) {
                                if (val != null && val.trim().length > 20) {
                                  return 'El teléfono no puede exceder 20 caracteres.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Fecha de Nacimiento (Paciente)
                            InkWell(
                              onTap: _seleccionarFechaNacimiento,
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de Nacimiento',
                                  prefixIcon: Icon(Icons.cake_outlined),
                                  suffixIcon: Icon(Icons.calendar_month_rounded),
                                ),
                                child: Text(
                                  _fechaNacimiento != null
                                      ? '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}'
                                      : 'No especificada (Tocar para elegir)',
                                  style: TextStyle(
                                    color: _fechaNacimiento != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Save Button
                            ElevatedButton(
                              onPressed: _isSaving ? null : _guardarPerfil,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save_rounded, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Guardar Cambios',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
