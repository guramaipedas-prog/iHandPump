class Shipment {
  final String id;
  final String? pengirim;
  final String? barang;
  final String? armada;
  final String? driver;
  final String? nopol;
  final String asal;
  final String tujuan;
  final String status;
  final String? lokasi;
  final double? lat;
  final double? lng;
  final int? progress;
  final String? eta;
  final List<ShipmentHistory>? history;

  Shipment({
    required this.id,
    this.pengirim,
    this.barang,
    this.armada,
    this.driver,
    this.nopol,
    required this.asal,
    required this.tujuan,
    this.status = 'loading',
    this.lokasi,
    this.lat,
    this.lng,
    this.progress,
    this.eta,
    this.history,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'] ?? '',
      pengirim: json['pengirim'],
      barang: json['barang'],
      armada: json['armada'],
      driver: json['driver'],
      nopol: json['nopol'],
      asal: json['asal'] ?? '',
      tujuan: json['tujuan'] ?? '',
      status: json['status'] ?? 'loading',
      lokasi: json['lokasi'],
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      progress: json['progress'],
      eta: json['eta'],
      history: json['history'] != null
          ? (json['history'] as List).map((e) => ShipmentHistory.fromJson(e)).toList()
          : null,
    );
  }
}

class ShipmentHistory {
  final String title;
  final String? subtitle;
  final bool done;
  final bool active;

  ShipmentHistory({
    required this.title,
    this.subtitle,
    this.done = false,
    this.active = false,
  });

  factory ShipmentHistory.fromJson(Map<String, dynamic> json) {
    return ShipmentHistory(
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      done: json['done'] ?? false,
      active: json['active'] ?? false,
    );
  }
}

class PositionUpdate {
  final double lat;
  final double lng;
  final String? lokasi;
  final int? progress;
  final String? nopol;

  PositionUpdate({
    required this.lat,
    required this.lng,
    this.lokasi,
    this.progress,
    this.nopol,
  });

  factory PositionUpdate.fromJson(Map<String, dynamic> json) {
    return PositionUpdate(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      lokasi: json['lokasi'],
      progress: json['progress'],
      nopol: json['nopol'],
    );
  }
}
