import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../support_points/data/support_points_repository.dart';
import '../data/alerts_map_repository.dart';

class AlertsMapPage extends ConsumerStatefulWidget {
  const AlertsMapPage({super.key});

  @override
  ConsumerState<AlertsMapPage> createState() => _AlertsMapPageState();
}

class _AlertsMapPageState extends ConsumerState<AlertsMapPage> {
  final _mapController = MapController();
  final _search = TextEditingController();
  Timer? _refreshTimer;
  bool _showAlerts = true;
  bool _showSupport = true;
  List<PublicAlertMarker> _alerts = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAlerts());
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) _loadAlerts();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _refreshTimer?.cancel();
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
    final supportPoints = ref.watch(supportPointsProvider);
    final center = LatLng(config.defaultLatitude, config.defaultLongitude);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Mapa'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sidePanel = _Panel(
            search: _search,
            showAlerts: _showAlerts,
            showSupport: _showSupport,
            onAlertsChanged: (value) => setState(() => _showAlerts = value),
            onSupportChanged: (value) => setState(() => _showSupport = value),
            onRefresh: _loadAlerts,
            loading: _loading,
          );
          final map = FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: center, initialZoom: config.defaultZoom),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'org.protegeela.app'),
              if (_showAlerts)
                CircleLayer(
                  circles: [
                    for (final alert in _alerts)
                      CircleMarker(
                        point: LatLng(alert.latitude, alert.longitude),
                        radius: alert.radiusMeters.toDouble(),
                        useRadiusInMeter: true,
                        color: AppColors.emergency.withOpacity(0.18),
                        borderColor: AppColors.emergency,
                        borderStrokeWidth: 2,
                      ),
                  ],
                ),
              if (_showSupport)
                supportPoints.when(
                  loading: () => const MarkerLayer(markers: []),
                  error: (_, __) => const MarkerLayer(markers: []),
                  data: (items) => MarkerLayer(
                    markers: [
                      for (final item in items)
                        Marker(
                          point: LatLng(item.latitude, item.longitude),
                          width: 44,
                          height: 44,
                          child: Tooltip(
                            message: item.name,
                            child: const Icon(Icons.local_hospital, color: AppColors.safe, size: 34),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );

          if (constraints.maxWidth >= 900) {
            return Row(children: [SizedBox(width: 340, child: sidePanel), Expanded(child: map)]);
          }
          return Column(children: [SizedBox(height: 220, child: sidePanel), Expanded(child: map)]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapController.move(center, config.defaultZoom),
        tooltip: 'Centralizar mapa',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.search,
    required this.showAlerts,
    required this.showSupport,
    required this.onAlertsChanged,
    required this.onSupportChanged,
    required this.onRefresh,
    required this.loading,
  });

  final TextEditingController search;
  final bool showAlerts;
  final bool showSupport;
  final ValueChanged<bool> onAlertsChanged;
  final ValueChanged<bool> onSupportChanged;
  final VoidCallback onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: search, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Buscar area')),
          const SizedBox(height: 12),
          SwitchListTile(value: showAlerts, onChanged: onAlertsChanged, title: const Text('Alertas aproximados')),
          SwitchListTile(value: showSupport, onChanged: onSupportChanged, title: const Text('Pontos de apoio')),
          const Divider(),
          const ListTile(leading: Icon(Icons.circle, color: AppColors.emergency), title: Text('Area aproximada de alerta')),
          const ListTile(leading: Icon(Icons.local_hospital, color: AppColors.safe), title: Text('Servico ou ponto de apoio')),
          const SizedBox(height: 8),
          const Text('Nao confronte possiveis agressores. Ajude com seguranca e acione canais oficiais quando necessario.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: loading ? null : onRefresh, icon: const Icon(Icons.refresh), label: const Text('Atualizar')),
        ],
      ),
    );
  }
}
