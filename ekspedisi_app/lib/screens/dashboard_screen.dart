import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'customers_screen.dart';
import 'drivers_screen.dart';
import 'billing_screen.dart';
import 'fuel_prices_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.loadAvailablePeriods();
      provider.loadDashboardStats();
      provider.loadFuelPrices();
    });
  }

  String formatRupiah(double? value) {
    if (value == null) return 'Rp 0';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
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
            final selectedMonth = provider.selectedMonth;
            final selectedYear = provider.selectedYear;

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
                      provider.clearPeriod();
                    } else if (selectedYear != null) {
                      provider.selectPeriod(value, selectedYear);
                    } else if (sortedYears.isNotEmpty) {
                      provider.selectPeriod(value, sortedYears.first);
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
                      provider.clearPeriod();
                    } else if (selectedMonth != null) {
                      provider.selectPeriod(selectedMonth, value);
                    } else {
                      // Pick the latest available month for this year
                      final availableMonths = periods
                          .where((p) => p['year'] == value)
                          .map((p) => p['month'] as int)
                          .toList()
                        ..sort((a, b) => b.compareTo(a));
                      if (availableMonths.isNotEmpty) {
                        provider.selectPeriod(availableMonths.first, value);
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
              provider.loadDashboardStats(
                month: provider.selectedMonth,
                year: provider.selectedYear,
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.dashboardStats == null) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final stats = provider.dashboardStats;
          if (stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat data', style: TextStyle(color: AppTheme.muted)),
                  TextButton(
                    onPressed: () => provider.loadDashboardStats(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboardStats(
              month: provider.selectedMonth,
              year: provider.selectedYear,
            ),
            color: AppTheme.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      label: 'Total Orders',
                      value: '${stats.orders.totalOrders ?? 0}',
                      color: AppTheme.primary,
                      icon: Icons.inventory_2,
                    ),
                    _StatCard(
                      label: 'Dalam Perjalanan',
                      value: '${stats.orders.jalan ?? 0}',
                      color: AppTheme.yellow,
                      icon: Icons.local_shipping,
                    ),
                    _StatCard(
                      label: 'Selesai',
                      value: '${stats.orders.selesai ?? 0}',
                      color: AppTheme.green,
                      icon: Icons.check_circle,
                    ),
                    _StatCard(
                      label: 'Piutang',
                      value: formatRupiah(stats.billing?.totalPiutang),
                      color: AppTheme.red,
                      icon: Icons.account_balance_wallet,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text('Menu Cepat', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _QuickAction(
                      icon: Icons.people,
                      label: 'Customers',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomersScreen()),
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.person,
                      label: 'Drivers',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DriversScreen()),
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.receipt_long,
                      label: 'Penagihan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BillingScreen()),
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.local_gas_station,
                      label: 'Harga BBM',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FuelPricesScreen()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Status Breakdown
                Text('Status Orders', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _StatusRow(label: 'Menunggu', value: stats.orders.menunggu ?? 0, color: AppTheme.muted),
                        _StatusRow(label: 'Dijadwalkan', value: stats.orders.dijadwalkan ?? 0, color: AppTheme.blue),
                        _StatusRow(label: 'Muat', value: stats.orders.muat ?? 0, color: AppTheme.purple),
                        _StatusRow(label: 'Jalan', value: stats.orders.jalan ?? 0, color: AppTheme.yellow),
                        _StatusRow(label: 'Bongkar', value: stats.orders.bongkar ?? 0, color: AppTheme.primary),
                        _StatusRow(label: 'Selesai', value: stats.orders.selesai ?? 0, color: AppTheme.green),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatusRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
