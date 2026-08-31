import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_state_view.dart';
import '../../../core/widgets/quick_exit_button.dart';
import '../data/safety_content_repository.dart';

class SafetyContentPage extends ConsumerWidget {
  const SafetyContentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contents = ref.watch(safetyContentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orientacoes'), actions: const [QuickExitButton()]),
      body: contents.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AppStateView(title: 'Erro', message: 'Nao foi possivel carregar orientacoes.', actionLabel: 'Tentar novamente', onAction: () => ref.invalidate(safetyContentsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return const AppStateView(title: 'Sem conteudos publicados', message: 'Conteudos podem ser gerenciados pelo painel administrativo.');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Se nao for seguro ler agora, use a Saida rapida. Esta acao nao apaga o historico do navegador.'),
                ),
              ),
              const SizedBox(height: 12),
              for (final item in items)
                Card(
                  child: ExpansionTile(
                    title: Text(item.title),
                    subtitle: Text(item.summary),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(item.content),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
