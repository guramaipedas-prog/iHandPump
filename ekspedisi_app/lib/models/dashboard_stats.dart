class DashboardStats {
  final OrderStats orders;
  final BillingStats? billing;
  final int? todayOrders;
  final int? activeDrivers;

  DashboardStats({
    required this.orders,
    this.billing,
    this.todayOrders,
    this.activeDrivers,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      orders: OrderStats.fromJson(json['orders'] ?? {}),
      billing: json['billing'] != null ? BillingStats.fromJson(json['billing']) : null,
      todayOrders: json['today_orders'],
      activeDrivers: json['active_drivers'],
    );
  }
}

class OrderStats {
  final int? totalOrders;
  final int? menunggu;
  final int? dijadwalkan;
  final int? muat;
  final int? jalan;
  final int? bongkar;
  final int? selesai;

  OrderStats({
    this.totalOrders,
    this.menunggu,
    this.dijadwalkan,
    this.muat,
    this.jalan,
    this.bongkar,
    this.selesai,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      totalOrders: json['total_orders'] ?? json['count'],
      menunggu: json['menunggu'],
      dijadwalkan: json['dijadwalkan'],
      muat: json['muat'],
      jalan: json['jalan'],
      bongkar: json['bongkar'],
      selesai: json['selesai'],
    );
  }
}

class BillingStats {
  final int? totalTagihan;
  final int? belumLunas;
  final int? sudahLunas;
  final double? totalPiutang;
  final double? totalTerbayar;

  BillingStats({
    this.totalTagihan,
    this.belumLunas,
    this.sudahLunas,
    this.totalPiutang,
    this.totalTerbayar,
  });

  factory BillingStats.fromJson(Map<String, dynamic> json) {
    return BillingStats(
      totalTagihan: json['total_tagihan'] != null ? (json['total_tagihan'] as num).toInt() : null,
      belumLunas: json['belum_lunas'] != null ? (json['belum_lunas'] as num).toInt() : null,
      sudahLunas: json['sudah_lunas'] != null ? (json['sudah_lunas'] as num).toInt() : null,
      totalPiutang: json['total_piutang'] != null ? (json['total_piutang'] as num).toDouble() : null,
      totalTerbayar: json['total_terbayar'] != null ? (json['total_terbayar'] as num).toDouble() : null,
    );
  }
}
