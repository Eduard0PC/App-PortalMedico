import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../shared/models.dart';

class SpecialtyStep extends StatelessWidget {
  final List<Especialidad> especialidades;
  final Especialidad? selectedSpecialty;
  final ValueChanged<Especialidad> onSpecialtySelected;

  const SpecialtyStep({
    super.key,
    required this.especialidades,
    required this.selectedSpecialty,
    required this.onSpecialtySelected,
  });

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
        return Icons.medical_services_rounded;
      default:
        return Icons.healing_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ...especialidades.map((spec) {
          final isSelected = selectedSpecialty?.idEspecialidad == spec.idEspecialidad;
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
              onTap: () => onSpecialtySelected(spec),
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
}
