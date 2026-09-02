import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnonymousReportPage extends ConsumerWidget {
  const AnonymousReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denúncia anônima'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Como usar a denúncia anônima', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  Text(
                    'Se você estiver em risco imediato, priorize sair do local, procurar ajuda de pessoas próximas e acionar canais oficiais. A denúncia anônima pode ser usada para registrar o ocorrido sem identificar você no momento do relato.',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('O que fazer agora', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  Text('1. Se a situação for imediata, vá para um local seguro, ligue para emergência ou procure ajuda de vizinhos, familiares ou profissionais.'),
                  SizedBox(height: 8),
                  Text('2. Grave detalhes importantes: local, horário, ameaças, pessoas envolvidas e qualquer informação útil para a investigação.'),
                  SizedBox(height: 8),
                  Text('3. Use a denúncia anônima para registrar fatos sem expor sua identidade e, quando possível, informe uma pessoa de confiança.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Números úteis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  ListTile(leading: Icon(Icons.phone), title: Text('190 - Polícia Militar'), subtitle: Text('Emergência e atendimento imediato')),
                  ListTile(leading: Icon(Icons.phone), title: Text('181 - Denúncia anônima'), subtitle: Text('Atendimento de denúncia sem identificação')),
                  ListTile(leading: Icon(Icons.phone), title: Text('180 - Central do atendimento à mulher'), subtitle: Text('Atendimento específico para violência contra a mulher')),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No app', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12),
                  Text('Quando você apertar o botão de ajuda por 5 segundos, a localização aproximada será enviada para o mapa e ficará visível em tempo real para a equipe e para quem precisa de suporte. O app não substitui a polícia nem o atendimento oficial.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => context.go('/delegacia-da-mulher'),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Ver orientações da Delegacia da Mulher'),
          ),
        ],
      ),
    );
  }
}
