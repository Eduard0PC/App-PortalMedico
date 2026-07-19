import 'package:flutter/material.dart';
import '../../../core/app_state.dart';
import '../../../core/theme.dart';
import '../../../shared/models.dart';

class AppointmentTile extends StatefulWidget {
  final Cita cita;

  const AppointmentTile({
    super.key,
    required this.cita,
  });

  @override
  State<AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<AppointmentTile> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showAtenderDialog(BuildContext context, AppState appState) {
    _notesController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.rate_review_outlined, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Atender: ${widget.cita.nombrePaciente}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Motivo de consulta: "${widget.cita.motivoConsulta}"',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notas Médicas y Diagnóstico',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 5,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Escriba aquí los síntomas, diagnóstico, prescripción médica o notas...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final notes = _notesController.text.trim();
              if (notes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, ingrese las notas médicas antes de completar.'),
                    backgroundColor: AppTheme.error,
                  ),
                );
                return;
              }
              
              appState.atenderCita(widget.cita.idCita, notes);
              Navigator.pop(context); // Dismiss dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Consulta registrada como Atendida.'),
                  backgroundColor: AppTheme.secondary,
                ),
              );
            },
            child: const Text('Guardar y Completar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isAttended = widget.cita.estado == 'Atendida';
    final accentColor = isAttended ? AppTheme.secondary : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: accentColor, width: 5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row with Time Slot & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.cita.horaInicio} - ${widget.cita.horaFin}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isAttended ? const Color(0xFFE6F7F0) : AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.cita.estado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Patient Name
            Text(
              widget.cita.nombrePaciente,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            
            // Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Motivo: ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textSecondary),
                ),
                Expanded(
                  child: Text(
                    widget.cita.motivoConsulta,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            
            // Medical Notes (if attended)
            if (isAttended && widget.cita.notaMedica != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Text(
                'Notas Médicas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.secondary),
              ),
              const SizedBox(height: 4),
              Text(
                widget.cita.notaMedica!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
            
            // Action Button (if programada)
            if (!isAttended) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showAtenderDialog(context, appState),
                icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
                label: const Text('Atender Consulta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
