import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickExitButton extends StatelessWidget {
  const QuickExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.go('/neutral'),
      icon: const Icon(Icons.exit_to_app),
      label: const Text('Saida rapida'),
    );
  }
}
