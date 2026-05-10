import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadAvailablePeriods();
      provider.loadBilling(
        month: provider.billingMonth,
        year: provider.billingYear,
      );
    });
  }

  String formatRupiah(double? value) {
    if (value == null) return 'Rp 0';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
  }

  String formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final dt = DateTime.parse(tanggal);
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return tanggal;
    }
  }

  String _monthName(int month) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final periods = provider.availablePeriods;
            final selectedMonth = provider.billingMonth;
            final selectedYear = provider.billingYear;

            // Extract unique years
            final years = <int>{};
            for (final p in periods) {
              years.add(p['year'] as int);
            }
            final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

            // Filter months for selected year
            final monthsForYear = <int>{};
            if (selectedYear != null) {
              for (final p in periods) {
                if (p['year'] == selectedYear) {
                  monthsForYear.add(p['month'] as int);
                }
              }
            } else {
              for (final p in periods) {
                monthsForYear.add(p['month'] as int);
              }
            }
            final sortedMonths = monthsForYear.toList()..sort((a, b) => b.compareTo(a));

            return Row(
              children: [
                // Month Dropdown
                DropdownButton<int?>(
                  value: selectedMonth,
                  isDense: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  dropdownColor: AppTheme.card,
                  hint: const Text('Bulan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua', style: TextStyle(fontSize: 13))),
                    ...sortedMonths.map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(_monthName(m), style: const TextStyle(fontSize: 13)),
                    )),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      provider.clearBillingPeriod();
                    } else if (selectedYear != null) {
                      provider.selectBillingPeriod(value, selectedYear);
                    } else if (sortedYears.isNotEmpty) {
                      provider.selectBillingPeriod(value, sortedYears.first);
                    }
                  },
                ),
                const SizedBox(width: 8),
                // Year Dropdown
                DropdownButton<int?>(
                  value: selectedYear,
                  isDense: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  dropdownColor: AppTheme.card,
                  hint: const Text('Tahun', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua', style: TextStyle(fontSize: 13))),
                    ...sortedYears.map((y) => DropdownMenuItem(
                      value: y,
                      child: Text('$y', style: const TextStyle(fontSize: 13)),
                    )),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      provider.clearBillingPeriod();
                    } else if (selectedMonth != null) {
                      provider.selectBillingPeriod(selectedMonth, value);
                    } else {
                      final availableMonths = periods
                          .where((p) => p['year'] == value)
                          .map((p) => p['month'] as int)
                          .toList()
                        ..sort((a, b) => b.compareTo(a));
                      if (availableMonths.isNotEmpty) {
                        provider.selectBillingPeriod(availableMonths.first, value);
                      }
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = context.read<AppProvider>();
              provider.loadBilling(
                month: provider.billingMonth,
                year: provider.billingYear,
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.billingOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (provider.billingOrders.isEmpty) {
            return const Center(child: Text('Belum ada tagihan', style: TextStyle(color: AppTheme.muted)));
          }

          double totalPiutang = 0;
          double totalLunas = 0;
          for (final o in provider.billingOrders) {
            if (o.isLunas) {
              totalLunas += o.nilaiTagihan ?? 0;
            } else {
              totalPiutang += o.nilaiTagihan ?? 0;
            }
          }

          return Column(
            children: [
              // Summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(formatRupiah(totalPiutang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.red)),
                              const SizedBox(height: 4),
                              const Text('Piutang', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(formatRupiah(totalLunas), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.green)),
                              const SizedBox(height: 4),
                              const Text('Lunas', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadBilling(
                    month: provider.billingMonth,
                    year: provider.billingYear,
                  ),
                  color: AppTheme.primary,
                  child: ListView.builder(
                    itemCount: provider.billingOrders.length,
                    itemBuilder: (context, index) {
                      final order = provider.billingOrders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(order.id),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(order.customerNama),
                              Text(
                                formatTanggal(order.tanggal ?? order.createdAt),
                                style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(formatRupiah(order.nilaiTagihan), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              StatusBadge(status: order.statusTagihan ?? 'BELUM'),
                            ],
                          ),
                          onTap: () => _showUpdateDialog(order),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateDialog(Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Update Status Tagihan'),
        content: Text('${order.id} - ${order.customerNama}\nTagihan: ${formatRupiah(order.nilaiTagihan)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          if (order.statusTagihan != 'LUNAS')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AppProvider>().updateBillingStatus(order.id, 'LUNAS');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
              child: const Text('Tandai Lunas'),
            ),
          if (order.statusTagihan != 'BELUM')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AppProvider>().updateBillingStatus(order.id, 'BELUM');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
              child: const Text('Tandai Belum'),
            ),
        ],
      ),
    );
  }
}
