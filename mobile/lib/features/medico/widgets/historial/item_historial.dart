import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models.dart';

class ItemHistorial extends StatelessWidget {
  final Cita cita;

  const ItemHistorial({
    super.key,
    required this.cita,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("d 'de' MMMM, yyyy", 'es').format(cita.fecha);
    
    Color badgeColor;
    Color badgeTextColor;
    switch (cita.estado) {
      case 'Atendida':
        badgeColor = const Color(0xFFE6F7F0);
        badgeTextColor = AppTheme.secondary;
        break;
      case 'Programada':
        badgeColor = AppTheme.primaryLight;
        badgeTextColor = AppTheme.primary;
        break;
      case 'Cancelada':
      default:
        badgeColor = const Color(0xFFFDE8E8);
        badgeTextColor = AppTheme.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date, Time & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$formattedDate a las ${cita.horaInicio}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  cita.estado,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Specialty & Doctor
          Text(
            '${cita.especialidad.nombre} - ${cita.medico.nombreCompleto}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),

          // Reason
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
              children: [
                const TextSpan(
                  text: 'Motivo: ',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                TextSpan(text: cita.motivoConsulta),
              ],
            ),
          ),
          
          // Medical Notes
          if (cita.notaMedica != null && cita.notaMedica!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),
            const Text(
              'Notas Médicas:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cita.notaMedica!,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
