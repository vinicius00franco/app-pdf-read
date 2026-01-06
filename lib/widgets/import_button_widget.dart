import 'package:flutter/material.dart';

class ImportButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const ImportButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text("Importar PDF"),
    );
  }
}