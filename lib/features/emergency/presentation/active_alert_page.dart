import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/emergency_call_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/app_state_view.dart';
import '../../../core/widgets/quick_exit_button.dart';
import '../data/emergency_controller.dart';
import '../data/emergency_repository.dart';
import '../data/emergency_services_repository.dart';

class ActiveAlertPage extends ConsumerWidget {
  const ActiveAlertPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyControllerProvider);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alerta ativo'), actions: const [QuickExitButton()]),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AppStateView(
          title: 'Alerta nao carregado',
          message: 'Tente novamente ou volte para o inicio.',
          actionLabel: 'Inicio',
          onAction: () => context.go('/home'),
        ),
        data: (value) {
          final alert = value.activeAlert;
          if (alert == null) {
            return AppStateView(
              title: 'Nenhum alerta ativo',
              message: 'Quando um alerta for confirmado pelo servidor, ele aparecera aqui.',
              actionLabel: 'Voltar ao inicio',
              onAction: () => context.go('/home'),
            );
          }
          return FutureBuilder(
            future: ref.read(emergencyRepositoryProvider).latestLocation(alert.id),
            builder: (context, snapshot) {
              final location = snapshot.data;
              final center = LatLng(location?.latitude ?? config.defaultLatitude, location?.longitude ?? config.defaultLongitude);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoTile(label: 'Status', value: alert.status),
                      _InfoTile(label: 'Inicio', value: alert.startedAt.toLocal().toString()),
                      _InfoTile(label: 'Precisao', value: location == null ? 'Indisponivel' : '${location.accuracy.round()} m'),
                      const _InfoTile(label: 'Contatos avisados', value: 'Verifique confirmacoes em tempo real'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 340,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        options: MapOptions(initialCenter: center, initialZoom: 15),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'org.protegeela.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: center,
                                width: 48,
                                height: 48,
                                child: const Icon(Icons.location_pin, color: AppColors.emergency, size: 42),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('O navegador pode limitar atualizacoes quando o app estiver fechado. Se estiver em perigo imediato, acione tambem canais oficiais disponiveis.'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _confirmCall(context, ref),
                        icon: const Icon(Icons.call),
                        label: const Text('Ligar para emergencia'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _updateLocation(context, ref, alert.id),
                        icon: const Icon(Icons.my_location),
                        label: const Text('Atualizar localizacao'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _close(context, ref),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Estou em local seguro'),
                      ),
                      TextButton.icon(
                        onPressed: () => _close(context, ref),
                        icon: const Icon(Icons.close),
                        label: const Text('Encerrar alerta'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmCall(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar ligacao'),
        content: const Text('Seu dispositivo tentara iniciar uma chamada. O ProtegeEla registra apenas o uso do botao, nao o conteudo da chamada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ligar')),
        ],
      ),
    );
    if (ok == true) {
      final service = await ref.read(emergencyServicesRepositoryProvider).firstActive();
      if (service == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum servico de emergencia ativo foi configurado.')));
        return;
      }
      final launched = await ref.read(emergencyCallServiceProvider).call(service!.phone);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nao foi possivel iniciar a ligacao. Copie o numero configurado na sua regiao.')));
      }
    }
  }

  Future<void> _updateLocation(BuildContext context, WidgetRef ref, String alertId) async {
    try {
      final location = await ref.read(locationServiceProvider).captureCurrent();
      await ref.read(emergencyRepositoryProvider).updateLocation(alertId: alertId, location: location);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Localizacao atualizada.')));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Localizacao indisponivel agora. O alerta continua ativo.')));
    }
  }

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encerrar alerta?'),
        content: const Text('O link de acompanhamento sera revogado e as atualizacoes de localizacao serao interrompidas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, 'safe'), child: const Text('Estou segura')),
          OutlinedButton(onPressed: () => Navigator.pop(context, 'help_received'), child: const Text('Recebi ajuda')),
        ],
      ),
    );
    if (reason == null) return;
    await ref.read(emergencyControllerProvider.notifier).closeAlert(reason: reason);
    if (context.mounted) context.go('/home');
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}
