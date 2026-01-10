import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class ImportButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const ImportButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.upload_file, size: 24),
      label: const Text("Importar PDF"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}