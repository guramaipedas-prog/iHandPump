import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class FuelPricesScreen extends StatefulWidget {
  const FuelPricesScreen({super.key});

  @override
  State<FuelPricesScreen> createState() => _FuelPricesScreenState();
}

class _FuelPricesScreenState extends State<FuelPricesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadFuelPrices();
    });
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⛽ Harga BBM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().loadFuelPrices(),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.fuelPrices.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final prices = provider.fuelPrices.values.toList();
          if (prices.isEmpty) {
            return const Center(
              child: Text('Belum ada data harga BBM', style: TextStyle(color: AppTheme.muted)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final fuel = prices[index];
              return _FuelPriceCard(
                jenis: fuel['jenis'],
                nama: fuel['nama'],
                harga: (fuel['harga'] as num).toDouble(),
                satuan: fuel['satuan'] ?? 'liter',
                updatedAt: fuel['updated_at'] ?? '',
                onUpdate: (newHarga) async {
                  try {
                    await provider.updateFuelPrice(fuel['jenis'], newHarga);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harga ${fuel['nama']} diupdate')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal update: $e')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FuelPriceCard extends StatefulWidget {
  final String jenis;
  final String nama;
  final double harga;
  final String satuan;
  final String updatedAt;
  final Future<void> Function(double) onUpdate;

  const _FuelPriceCard({
    required this.jenis,
    required this.nama,
    required this.harga,
    required this.satuan,
    required this.updatedAt,
    required this.onUpdate,
  });

  @override
  State<_FuelPriceCard> createState() => _FuelPriceCardState();
}

class _FuelPriceCardState extends State<_FuelPriceCard> {
  late TextEditingController _ctrl;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.harga.toInt().toString());
  }

  @override
  void didUpdateWidget(covariant _FuelPriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.harga != widget.harga) {
      _ctrl.text = widget.harga.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.nama,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.jenis,
                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(widget.harga)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            Text(
              'per ${widget.satuan}',
              style: const TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Harga Baru',
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          final newHarga = double.tryParse(_ctrl.text);
                          if (newHarga == null || newHarga < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Harga tidak valid')),
                            );
                            return;
                          }
                          setState(() => _isUpdating = true);
                          await widget.onUpdate(newHarga);
                          setState(() => _isUpdating = false);
                        },
                  child: _isUpdating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
