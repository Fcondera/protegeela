import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ProtegeEla', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  const Text(
                    'Acesse o protótipo e explore a experiência inicial do app.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/privacidade'),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continuar'),
                  ),
                  TextButton(onPressed: () => context.go('/login'), child: const Text('Ja tenho conta')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
