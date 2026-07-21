import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class BarraEntradaChat extends StatelessWidget {
  final TextEditingController controlador;
  final bool estaEnviando;
  final VoidCallback alEnviar;

  const BarraEntradaChat({
    super.key,
    required this.controlador,
    required this.estaEnviando,
    required this.alEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: TextField(
                  controller: controlador,
                  enabled: !estaEnviando,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu consulta sobre médicos u horarios...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => alEnviar(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: estaEnviando ? Colors.grey.shade300 : AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: estaEnviando ? null : alEnviar,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: estaEnviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
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
