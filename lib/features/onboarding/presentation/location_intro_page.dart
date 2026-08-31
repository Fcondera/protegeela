import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LocationIntroPage extends StatelessWidget {
  const LocationIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localizacao')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.location_on_outlined, size: 56),
                const SizedBox(height: 16),
                Text('Permissao contextual', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text(
                  'Voce pode permitir localizacao agora ou somente ao pedir ajuda. Ausencia de GPS nunca bloqueia a criacao do alerta.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: () => context.go('/cadastro'), child: const Text('Criar conta')),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Entrar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
