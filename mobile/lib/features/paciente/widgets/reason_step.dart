import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ReasonStep extends StatelessWidget {
  final TextEditingController reasonController;

  const ReasonStep({
    super.key,
    required this.reasonController,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: reasonController,
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
}
