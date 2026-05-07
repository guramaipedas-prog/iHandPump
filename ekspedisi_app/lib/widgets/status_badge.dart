import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isShipment;

  const StatusBadge({super.key, required this.status, this.isShipment = false});

  Color get _color {
    final s = status.toLowerCase();
    if (isShipment) {
      switch (s) {
        case 'on-the-way': return AppTheme.primary;
        case 'delivered': return AppTheme.green;
        case 'loading': return AppTheme.blue;
        case 'pickup': return AppTheme.yellow;
        default: return AppTheme.muted;
      }
    }
    switch (s) {
      case 'menunggu': return AppTheme.muted;
      case 'dijadwalkan': return AppTheme.blue;
      case 'muat': return AppTheme.purple;
      case 'jalan': return AppTheme.yellow;
      case 'sampai': return AppTheme.primaryLight;
      case 'bongkar': return AppTheme.primary;
      case 'selesai': return AppTheme.green;
      case 'belum': return AppTheme.red;
      case 'lunas': return AppTheme.green;
      default: return AppTheme.muted;
    }
  }

  String get _label {
    final s = status.toUpperCase();
    if (isShipment) {
      switch (s) {
        case 'ON-THE-WAY': return '🚛 Dalam Perjalanan';
        case 'DELIVERED': return '✅ Selesai';
        case 'LOADING': return '⏳ Proses Muat';
        case 'PICKUP': return '🏁 Siap Berangkat';
        default: return s;
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
