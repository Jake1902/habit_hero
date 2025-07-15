import 'package:flutter/material.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Text(title, style: AppTextStyles.headline),
    );
  }
}
