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
      todayOrders: json['today_orders'] != null ? int.tryParse(json['today_orders'].toString()) : null,
      activeDrivers: json['active_drivers'] != null ? int.tryParse(json['active_drivers'].toString()) : null,
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
      totalOrders: json['total_orders'] != null ? int.tryParse(json['total_orders'].toString()) : json['count'] != null ? int.tryParse(json['count'].toString()) : null,
      menunggu: json['menunggu'] != null ? int.tryParse(json['menunggu'].toString()) : null,
      dijadwalkan: json['dijadwalkan'] != null ? int.tryParse(json['dijadwalkan'].toString()) : null,
      muat: json['muat'] != null ? int.tryParse(json['muat'].toString()) : null,
      jalan: json['jalan'] != null ? int.tryParse(json['jalan'].toString()) : null,
      bongkar: json['bongkar'] != null ? int.tryParse(json['bongkar'].toString()) : null,
      selesai: json['selesai'] != null ? int.tryParse(json['selesai'].toString()) : null,
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
      totalTagihan: json['total_tagihan'] != null ? int.tryParse(json['total_tagihan'].toString()) : null,
      belumLunas: json['belum_lunas'] != null ? int.tryParse(json['belum_lunas'].toString()) : null,
      sudahLunas: json['sudah_lunas'] != null ? int.tryParse(json['sudah_lunas'].toString()) : null,
      totalPiutang: json['total_piutang'] != null ? double.tryParse(json['total_piutang'].toString()) : null,
      totalTerbayar: json['total_terbayar'] != null ? double.tryParse(json['total_terbayar'].toString()) : null,
    );
  }
}
