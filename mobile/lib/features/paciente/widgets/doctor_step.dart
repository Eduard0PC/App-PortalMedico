import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../shared/models.dart';

class DoctorStep extends StatelessWidget {
  final List<Medico> filteredDoctors;
  final Especialidad selectedSpecialty;
  final Medico? selectedDoctor;
  final ValueChanged<Medico> onDoctorSelected;

  const DoctorStep({
    super.key,
    required this.filteredDoctors,
    required this.selectedSpecialty,
    required this.selectedDoctor,
    required this.onDoctorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.arrow_right_rounded, color: AppTheme.primary),
            Text(
              'Especialidad: ${selectedSpecialty.nombre}',
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
            final isSelected = selectedDoctor?.idMedico == doc.idMedico;
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
                onTap: () => onDoctorSelected(doc),
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
}
