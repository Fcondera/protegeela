import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_providers.dart';
import '../../../shared/models/safety_content.dart';
import '../../authentication/data/demo_session_repository.dart';

final safetyContentRepositoryProvider = Provider<SafetyContentRepository>((ref) {
  return SafetyContentRepository(ref.watch(supabaseClientProvider));
});

final safetyContentsProvider = FutureProvider<List<SafetyContent>>((ref) async {
  final demoActive = await ref.watch(demoSessionProvider.future);
  if (demoActive) {
    return const [
      SafetyContent(
        id: 'demo-safety-1',
        title: 'Como montar uma rede de apoio',
        summary: 'Combine sinais e permissoes com pessoas de confianca.',
        content: 'Escolha pessoas que voce confia, explique como elas podem ajudar e revise as permissoes de localizacao.',
        category: 'support_network',
        isPublished: true,
      ),
      SafetyContent(
        id: 'demo-safety-2',
        title: 'Privacidade no mapa',
        summary: 'Alertas publicos aparecem somente de forma aproximada.',
        content: 'A localizacao exata deve ficar restrita a voce e contatos autorizados durante um alerta ativo.',
        category: 'privacy',
        isPublished: true,
      ),
    ];
  }
  return ref.watch(safetyContentRepositoryProvider).published();
});

class SafetyContentRepository {
  const SafetyContentRepository(this._client);

  final SupabaseClient _client;

  Future<List<SafetyContent>> published() async {
    final rows = await _client.from('safety_contents').select().eq('is_published', true).order('title');
    return [for (final row in rows) SafetyContent.fromJson(row)];
  }
}
