import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models.dart';

class TarjetaCita extends StatelessWidget {
  final Cita cita;

  const TarjetaCita({
    super.key,
    required this.cita,
  });

  void _handleCancelCita(BuildContext context, AppState appState) {
    if (cita.esCancelable) {
      // Confirmation Dialog
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
              onPressed: () async {
                Navigator.pop(context); // Dismiss dialog
                try {
                  final success = await appState.cancelarCita(cita.idCita);
                  if (context.mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cita cancelada con éxito.'),
                        backgroundColor: AppTheme.secondary,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('AuthException: ', '')),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
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
                onPressed: () => _handleCancelCita(context, appState),
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
