import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class SugerenciasRapidasChat extends StatelessWidget {
  final List<String> sugerencias;
  final bool estaEnviando;
  final ValueChanged<String> alSeleccionarSugerencia;

  const SugerenciasRapidasChat({
    super.key,
    required this.sugerencias,
    required this.estaEnviando,
    required this.alSeleccionarSugerencia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 40, right: 16),
        scrollDirection: Axis.horizontal,
        itemCount: sugerencias.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sugerencia = sugerencias[index];
          return ActionChip(
            label: Text(
              sugerencia,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary,
              ),
            ),
            backgroundColor: AppTheme.primaryLight,
            side: BorderSide(
              color: AppTheme.primary.withValues(alpha: 0.2),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: estaEnviando ? null : () => alSeleccionarSugerencia(sugerencia),
          );
        },
      ),
    );
  }
}
