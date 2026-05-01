import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filterStatus = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadOrders();
    });
  }

  String formatRupiah(double? value) {
    if (value == null) return 'Rp 0';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Manajemen Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().loadOrders(status: _filterStatus.isEmpty ? null : _filterStatus),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(label: 'Semua', isActive: _filterStatus == '', onTap: () {
                  setState(() => _filterStatus = '');
                  context.read<AppProvider>().loadOrders();
                }),
                _FilterChip(label: 'Menunggu', isActive: _filterStatus == 'MENUNGGU', onTap: () {
                  setState(() => _filterStatus = 'MENUNGGU');
                  context.read<AppProvider>().loadOrders(status: 'MENUNGGU');
                }),
                _FilterChip(label: 'Jalan', isActive: _filterStatus == 'JALAN', onTap: () {
                  setState(() => _filterStatus = 'JALAN');
                  context.read<AppProvider>().loadOrders(status: 'JALAN');
                }),
                _FilterChip(label: 'Selesai', isActive: _filterStatus == 'SELESAI', onTap: () {
                  setState(() => _filterStatus = 'SELESAI');
                  context.read<AppProvider>().loadOrders(status: 'SELESAI');
                }),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }

                if (provider.error != null && provider.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!, style: const TextStyle(color: AppTheme.muted)),
                        TextButton(
                          onPressed: () => provider.loadOrders(status: _filterStatus.isEmpty ? null : _filterStatus),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.orders.isEmpty) {
                  return const Center(
                    child: Text('Belum ada orders', style: TextStyle(color: AppTheme.muted)),
                  );
                }

                return ListView.builder(
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return _OrderCard(
                      order: order,
                      onTap: () => _showOrderDetail(order),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrderDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showOrderDetail(Order order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.id, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Customer', value: order.customerNama),
            _DetailRow(label: 'Rute', value: order.rute),
            _DetailRow(label: 'Barang', value: order.jenisBarang ?? '-'),
            _DetailRow(label: 'Driver', value: order.driverNama ?? 'Belum diassign'),
            _DetailRow(label: 'Tagihan', value: formatRupiah(order.nilaiTagihan)),
            _DetailRow(label: 'Uang Jalan', value: formatRupiah(order.totalUangJalan)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(order),
                    child: const Text('Update Status'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(order);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(Order order) {
    final statuses = ['MENUNGGU', 'DIJADWALKAN', 'MUAT', 'JALAN', 'BONGKAR', 'SELESAI'];
    String selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Update Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((s) => RadioListTile<String>(
              title: Text(s),
              value: s,
              groupValue: selectedStatus,
              activeColor: AppTheme.primary,
              onChanged: (value) => setState(() => selectedStatus = value!),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              context.read<AppProvider>().updateOrderStatus(order.id, selectedStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus order ${order.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppProvider>().deleteOrder(order.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAddOrderDialog() {
    final idCtrl = TextEditingController();
    final customerCtrl = TextEditingController();
    final titkaACtrl = TextEditingController();
    final titikBCtrl = TextEditingController();
    final barangCtrl = TextEditingController();
    final tagihanCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Order Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'No Order *')),
              TextField(controller: customerCtrl, decoration: const InputDecoration(labelText: 'Customer *')),
              TextField(controller: titkaACtrl, decoration: const InputDecoration(labelText: 'Titik Muat (A) *')),
              TextField(controller: titikBCtrl, decoration: const InputDecoration(labelText: 'Titik Bongkar (B) *')),
              TextField(controller: barangCtrl, decoration: const InputDecoration(labelText: 'Jenis Barang')),
              TextField(controller: tagihanCtrl, decoration: const InputDecoration(labelText: 'Nilai Tagihan'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (idCtrl.text.isEmpty || customerCtrl.text.isEmpty || titkaACtrl.text.isEmpty || titikBCtrl.text.isEmpty) {
                return;
              }
              Navigator.pop(context);
              context.read<AppProvider>().createOrder({
                'id': idCtrl.text,
                'customer_nama': customerCtrl.text,
                'titik_a': titkaACtrl.text,
                'titik_b': titikBCtrl.text,
                'jenis_barang': barangCtrl.text,
                'nilai_tagihan': double.tryParse(tagihanCtrl.text) ?? 0,
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.customerNama, style: const TextStyle(color: AppTheme.white)),
              Text(order.rute, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              if (order.driverNama != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Driver: ${order.driverNama}', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? AppTheme.primary : AppTheme.border),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, color: isActive ? Colors.white : AppTheme.white)),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
