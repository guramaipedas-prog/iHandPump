class Driver {
  final int? id;
  final String nama;
  final String? telepon;
  final String? nopolTruck;
  final String? armada;
  final String status;
  final String? createdAt;

  Driver({
    this.id,
    required this.nama,
    this.telepon,
    this.nopolTruck,
    this.armada,
    this.status = 'AKTIF',
    this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      nama: json['nama'] ?? '',
      telepon: json['telepon'],
      nopolTruck: json['nopol_truck'],
      armada: json['armada'],
      status: json['status'] ?? 'AKTIF',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'telepon': telepon,
      'nopol_truck': nopolTruck,
      'armada': armada,
      'status': status,
    };
  }

  bool get isAvailable => status == 'AKTIF';
}
