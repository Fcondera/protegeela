import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_state_view.dart';
import '../data/support_points_repository.dart';

class SupportPointsPage extends ConsumerWidget {
  const SupportPointsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(supportPointsProvider);
    final config = ref.watch(appConfigProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Pontos de apoio'),
      ),
      body: points.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('assets/config/img/scrennshort.png'),
                width: 120,
                height: 120,
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
        error: (_, __) => AppStateView(title: 'Erro', message: 'Nao foi possivel carregar pontos de apoio.', actionLabel: 'Tentar novamente', onAction: () => ref.invalidate(supportPointsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return const AppStateView(
              title: 'Sem pontos cadastrados',
              message: 'Cadastre pontos verificados pelo painel administrativo. Dados de demo devem ser claramente identificados.',
            );
          }
          final map = FlutterMap(
            options: MapOptions(initialCenter: LatLng(config.defaultLatitude, config.defaultLongitude), initialZoom: config.defaultZoom),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'org.protegeela.app'),
              MarkerLayer(
                markers: [
                  for (final item in items)
                    Marker(
                      point: LatLng(item.latitude, item.longitude),
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.location_on, color: AppColors.safe, size: 36),
                    ),
                ],
              ),
            ],
          );
          final list = ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(item.isVerified ? Icons.verified : Icons.info_outline),
                title: Text(item.name),
                subtitle: Text('${item.category} - ${item.city}/${item.state}\n${item.address}'),
                isThreeLine: true,
              );
            },
          );
          if (MediaQuery.sizeOf(context).width >= 900) {
            return Row(children: [Expanded(child: map), SizedBox(width: 420, child: list)]);
          }
          return Column(children: [SizedBox(height: 320, child: map), Expanded(child: list)]);
        },
      ),
    );
  }
}
