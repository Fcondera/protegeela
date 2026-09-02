import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_back_button.dart';

class PrivacyIntroPage extends StatelessWidget {
  const PrivacyIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/apresentacao'),
        title: const Text('Privacidade'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Localizacao exata nao e publica', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text(
                'O mapa comunitario mostra apenas areas aproximadas. A localizacao exata so fica disponivel para voce e contatos autorizados durante um alerta ativo.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Navegadores podem limitar geolocalizacao, notificacoes e atualizacoes quando o app estiver fechado.',
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => context.go('/localizacao'), child: const Text('Entendi')),
            ],
          ),
        ),
      ),
    );
  }
}
