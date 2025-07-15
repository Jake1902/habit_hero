import 'package:flutter/material.dart';
import '../core/constants/radii.dart';
import '../core/constants/spacing.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = primary
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceVariant;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s32,
          vertical: AppSpacing.s12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r24),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
