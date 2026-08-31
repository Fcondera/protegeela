import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_state_view.dart';
import '../../../core/widgets/quick_exit_button.dart';
import '../../../features/emergency/data/emergency_controller.dart';
import '../../../features/emergency/presentation/emergency_button.dart';
import '../../../features/profile/data/profile_repository.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final emergency = ref.watch(emergencyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ProtegeEla'), actions: const [QuickExitButton()]),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const AppStateView(title: 'Algo deu errado', message: 'Nao foi possivel carregar seu perfil.'),
        data: (profile) {
          if (profile == null) {
            return const AppStateView(title: 'Perfil incompleto', message: 'Conclua seu perfil para usar o ProtegeEla.');
          }
          final activeAlert = emergency.valueOrNull?.activeAlert;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 12,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ola, ${profile.firstName}', style: Theme.of(context).textTheme.headlineMedium),
                            Text(activeAlert?.isActive == true ? 'Alerta ativo' : 'Voce esta segura?'),
                          ],
                        ),
                        if (activeAlert?.isActive == true)
                          FilledButton.icon(
                            onPressed: () => context.go('/alerta-ativo'),
                            icon: const Icon(Icons.warning_amber),
                            label: const Text('Ver alerta'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: EmergencyButton(
                        enabled: emergency.valueOrNull?.isSending != true,
                        onConfirmed: ({required isSilent}) async {
                          await ref.read(emergencyControllerProvider.notifier).createAlert(isSilent: isSilent);
                          if (context.mounted) context.go('/alerta-ativo');
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'O ProtegeEla ajuda voce a acionar sua rede de apoio. Ele nao substitui policia, servicos oficiais de emergencia ou atendimento medico.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (emergency.valueOrNull?.lastMessage != null &&
                        emergency.valueOrNull?.clientRequestId != null &&
                        emergency.valueOrNull?.activeAlert == null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(emergency.valueOrNull!.lastMessage!, textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => ref.read(emergencyControllerProvider.notifier).syncPendingAlert(),
                                icon: const Icon(Icons.sync),
                                label: const Text('Tentar sincronizar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 4 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _Shortcut(icon: Icons.map_outlined, label: 'Mapa', onTap: () => context.go('/mapa')),
                        _Shortcut(icon: Icons.people_outline, label: 'Contatos', onTap: () => context.go('/contatos')),
                        _Shortcut(icon: Icons.local_hospital_outlined, label: 'Apoio', onTap: () => context.go('/apoio')),
                        _Shortcut(icon: Icons.menu_book_outlined, label: 'Orientacoes', onTap: () => context.go('/orientacoes')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
