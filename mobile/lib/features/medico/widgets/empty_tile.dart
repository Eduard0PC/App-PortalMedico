import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class EmptyTile extends StatelessWidget {
  final String time;

  const EmptyTile({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
