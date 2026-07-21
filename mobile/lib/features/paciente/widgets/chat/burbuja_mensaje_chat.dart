import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/chat_message.dart';

class BurbujaMensajeChat extends StatelessWidget {
  final ChatMessage mensaje;

  const BurbujaMensajeChat({
    super.key,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!esUsuario) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: esUsuario
                    ? AppTheme.primary
                    : mensaje.isError
                        ? AppTheme.error.withValues(alpha: 0.1)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esUsuario ? 16 : 4),
                  bottomRight: Radius.circular(esUsuario ? 4 : 16),
                ),
                border: !esUsuario && !mensaje.isError
                    ? Border.all(color: Colors.grey.withValues(alpha: 0.2))
                    : mensaje.isError
                        ? Border.all(color: AppTheme.error.withValues(alpha: 0.3))
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: esUsuario
                          ? Colors.white
                          : mensaje.isError
                              ? AppTheme.error
                              : AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${mensaje.timestamp.hour.toString().padLeft(2, '0')}:${mensaje.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 10,
                        color: esUsuario
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (esUsuario) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
