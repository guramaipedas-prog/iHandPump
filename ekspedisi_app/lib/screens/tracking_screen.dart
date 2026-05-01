import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _resiCtrl = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Load orders untuk suggestions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (provider.orders.isEmpty) {
        provider.loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _resiCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📍 Tracking Pengiriman')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _resiCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nomor resi...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _resiCtrl.clear();
                          context.read<AppProvider>().clearTrackedShipment();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_resiCtrl.text.trim().isNotEmpty) {
                      context.read<AppProvider>().trackShipment(_resiCtrl.text.trim());
                    }
                  },
                  child: const Text('Lacak'),
                ),
              ],
            ),
          ),

          // Active Orders Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                final activeOrders = provider.orders
                    .where((o) => o.status != 'SELESAI')
                    .toList();

                if (activeOrders.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Wrap(
                  spacing: 8,
                  children: activeOrders.map((order) {
                    return _SuggestionChip(
                      label: order.id,
                      onTap: () => _track(order.id),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Result
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }

                if (provider.error != null && provider.trackedShipment == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppTheme.red),
                          const SizedBox(height: 12),
                          Text(provider.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
                        ],
                      ),
                    ),
                  );
                }

                final shipment = provider.trackedShipment;
                if (shipment == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_shipping, size: 64, color: AppTheme.muted),
                          const SizedBox(height: 16),
                          const Text(
                            'Masukkan nomor resi pengiriman Anda untuk melihat posisi dan status truk.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final lat = shipment.lat ?? -7.2575;
                final lng = shipment.lng ?? 112.7521;

                return Column(
                  children: [
                    // Info Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(shipment.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  StatusBadge(status: shipment.status, isShipment: true),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(label: 'Pengirim', value: shipment.pengirim ?? '-'),
                              _InfoRow(label: 'Barang', value: shipment.barang ?? '-'),
                              _InfoRow(label: 'Driver', value: shipment.driver ?? '-'),
                              _InfoRow(label: 'No Polisi', value: shipment.nopol ?? '-'),
                              _InfoRow(label: 'Asal → Tujuan', value: '${shipment.asal} → ${shipment.tujuan}'),
                              _InfoRow(label: 'Lokasi', value: shipment.lokasi ?? '-'),
                              if (shipment.progress != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Progres: ${shipment.progress}%', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: (shipment.progress! / 100).clamp(0.0, 1.0),
                                        backgroundColor: AppTheme.border,
                                        valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Map
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(lat, lng),
                              initialZoom: 13,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.ekspedisi_app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: LatLng(lat, lng),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _track(String resi) {
    _resiCtrl.text = resi;
    context.read<AppProvider>().trackShipment(resi);
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppTheme.card,
      side: const BorderSide(color: AppTheme.border),
      onPressed: onTap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
