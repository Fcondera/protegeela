import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/quick_exit_button.dart';
import '../../alerts_map/data/alerts_map_repository.dart';

class WomenPolicePage extends ConsumerStatefulWidget {
  const WomenPolicePage({super.key});

  @override
  ConsumerState<WomenPolicePage> createState() => _WomenPolicePageState();
}

class _WomenPolicePageState extends ConsumerState<WomenPolicePage> {
  Timer? _timer;
  List<PublicAlertMarker> _alerts = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAlerts());
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) _loadAlerts();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    setState(() => _loading = true);
    try {
      final demoAlerts = await ref.read(publicAlertMarkersProvider.future);
      _alerts = demoAlerts.isNotEmpty
          ? demoAlerts
          : await ref.read(alertsMapRepositoryProvider).publicAlertsInBounds(
              south: -90,
              west: -180,
              north: 90,
              east: 180,
            );
    } catch (_) {
      _alerts = const [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final center = LatLng(config.defaultLatitude, config.defaultLongitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delegacia da Mulher'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('O que fazer em caso de emergência', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    SizedBox(height: 12),
                    Text('1. Saia do local, se possível, e procure um lugar seguro, com pessoas de confiança ou em estabelecimento público.'),
                    SizedBox(height: 8),
                    Text('2. Registre a ocorrência e guarde provas, como mensagens, fotos, datas, horários, nomes e endereços.'),
                    SizedBox(height: 8),
                    Text('3. Se o risco for imediato, ligue para 190 ou 180 e procure atendimento oficial sem demora.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Orientações e cuidados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 12),
                    Text('• Não tente confrontar o agressor diretamente se isso aumentar o risco.'),
                    Text('• Salve evidências em segurança e mantenha o celular carregado.'),
                    Text('• Avise uma pessoa de confiança por mensagem ou ligação, se houver segurança para isso.'),
                    Text('• O mapa do app mostra a área aproximada do alerta em tempo real, e ajuda a sinalizar quem precisa de ajuda.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Números e canais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 12),
                    ListTile(leading: Icon(Icons.local_police), title: Text('190 - Polícia Militar'), subtitle: Text('Emergência e ajuda imediata')),
                    ListTile(leading: Icon(Icons.phone), title: Text('180 - Central da Mulher'), subtitle: Text('Atendimento específico para violência contra a mulher')),
                    ListTile(leading: Icon(Icons.report), title: Text('181 - Denúncia anônima'), subtitle: Text('Relate sem se identificar')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mapa em tempo real', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 320,
                      child: FlutterMap(
                        options: MapOptions(initialCenter: center, initialZoom: 11),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'org.protegeela.app',
                          ),
                          CircleLayer(
                            circles: [
                              for (final alert in _alerts)
                                CircleMarker(
                                  point: LatLng(alert.latitude, alert.longitude),
                                  radius: alert.radiusMeters.toDouble(),
                                  useRadiusInMeter: true,
                                  color: AppColors.emergency.withOpacity(0.2),
                                  borderColor: AppColors.emergency,
                                  borderStrokeWidth: 2,
                                ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              for (final alert in _alerts)
                                Marker(
                                  point: LatLng(alert.latitude, alert.longitude),
                                  width: 42,
                                  height: 42,
                                  child: const Icon(Icons.location_pin, color: AppColors.emergency, size: 38),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('Atualizando alertas em tempo real...'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/denuncia-anonima'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ir para denúncia anônima'),
            ),
          ],
        ),
      ),
    );
  }
}
