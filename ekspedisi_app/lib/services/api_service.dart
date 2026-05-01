import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/customer.dart';
import '../models/driver.dart';
import '../models/shipment.dart';
import '../models/dashboard_stats.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Ganti dengan URL backend Anda
  // Local: 'http://10.0.2.2:3000/api' (untuk Android emulator)
  // Local: 'http://localhost:3000/api' (untuk iOS simulator)
  // Production: 'https://your-domain.com/api'
  String baseUrl = 'https://ihandpump-production.up.railway.app/api';

  void setBaseUrl(String url) {
    baseUrl = url.endsWith('/api') ? url : '$url/api';
  }

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ==================== HEALTH ====================
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'), headers: headers)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== ORDERS ====================
  Future<List<Order>> getOrders({String? status, String? search}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/orders').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> orders = data['data'] ?? [];
        return orders.map((e) => Order.fromJson(e)).toList();
      }
    }
    throw Exception('Gagal mengambil data orders');
  }

  Future<Order> getOrder(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/$id'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Order.fromJson(data['data']);
      }
    }
    throw Exception('Order tidak ditemukan');
  }

  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Order.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal membuat order');
  }

  Future<Order> updateOrder(String id, Map<String, dynamic> orderData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id'),
      headers: headers,
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Order.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update order');
  }

  Future<void> deleteOrder(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/orders/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal menghapus order');
    }
  }

  Future<Order> updateOrderStatus(String id, String status, {String? keterangan}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/orders/$id/status'),
      headers: headers,
      body: jsonEncode({
        'status': status,
        'keterangan': keterangan,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Order.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update status');
  }

  Future<Order> assignDriver(String id, int driverId, String driverNama) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/orders/$id/assign-driver'),
      headers: headers,
      body: jsonEncode({
        'driver_id': driverId,
        'driver_nama': driverNama,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Order.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal assign driver');
  }

  // ==================== CUSTOMERS ====================
  Future<List<Customer>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> customers = data['data'] ?? [];
        return customers.map((e) => Customer.fromJson(e)).toList();
      }
    }
    throw Exception('Gagal mengambil data customers');
  }

  Future<Customer> createCustomer(Map<String, dynamic> customerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: headers,
      body: jsonEncode(customerData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Customer.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal membuat customer');
  }

  Future<Customer> updateCustomer(int id, Map<String, dynamic> customerData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/customers/$id'),
      headers: headers,
      body: jsonEncode(customerData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Customer.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update customer');
  }

  Future<void> deleteCustomer(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/customers/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal menghapus customer');
    }
  }

  // ==================== DRIVERS ====================
  Future<List<Driver>> getDrivers({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/drivers').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> drivers = data['data'] ?? [];
        return drivers.map((e) => Driver.fromJson(e)).toList();
      }
    }
    throw Exception('Gagal mengambil data drivers');
  }

  Future<List<Driver>> getAvailableDrivers() async {
    final response = await http.get(Uri.parse('$baseUrl/drivers/available/list'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> drivers = data['data'] ?? [];
        return drivers.map((e) => Driver.fromJson(e)).toList();
      }
    }
    throw Exception('Gagal mengambil data drivers tersedia');
  }

  Future<Driver> createDriver(Map<String, dynamic> driverData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/drivers'),
      headers: headers,
      body: jsonEncode(driverData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Driver.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal membuat driver');
  }

  Future<Driver> updateDriver(int id, Map<String, dynamic> driverData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/drivers/$id'),
      headers: headers,
      body: jsonEncode(driverData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Driver.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update driver');
  }

  Future<void> deleteDriver(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/drivers/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal menghapus driver');
    }
  }

  Future<void> createDriverLog(Map<String, dynamic> logData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/drivers/logs'),
      headers: headers,
      body: jsonEncode(logData),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal mengirim log');
    }
  }

  Future<List<dynamic>> getDriverLogs({String? orderId}) async {
    final queryParams = <String, String>{};
    if (orderId != null) queryParams['order_id'] = orderId;

    final uri = Uri.parse('$baseUrl/drivers/logs/all').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'] ?? [];
      }
    }
    throw Exception('Gagal mengambil driver logs');
  }

  // ==================== TRACKING / SHIPMENTS ====================
  Future<Shipment> trackShipment(String resi) async {
    final response = await http.get(Uri.parse('$baseUrl/track/$resi'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Shipment.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Resi tidak ditemukan');
  }

  Future<PositionUpdate> getPosition(String resi) async {
    final response = await http.get(Uri.parse('$baseUrl/track/$resi/position'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return PositionUpdate.fromJson(data['data']);
      }
    }
    throw Exception('Gagal mengambil posisi');
  }

  Future<List<Shipment>> getShipments() async {
    final response = await http.get(Uri.parse('$baseUrl/shipments'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> shipments = data['data'] ?? [];
        return shipments.map((e) => Shipment.fromJson(e)).toList();
      }
    }
    throw Exception('Gagal mengambil data shipments');
  }

  Future<void> createShipment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shipments'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal membuat shipment');
    }
  }

  Future<void> updateShipment(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/shipments/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update shipment');
    }
  }

  Future<void> deleteShipment(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/shipments/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal menghapus shipment');
    }
  }

  Future<void> updatePosition(String id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/shipments/$id/position'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update posisi');
    }
  }

  // ==================== BILLING ====================
  Future<List<Order>> getBilling({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/billing').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> orders = data['data'] ?? [];
        return orders.map((e) => Order.fromJson(e)).toList();
      }
    }
    throw Exception('Gagal mengambil data billing');
  }

  Future<Order> updateBillingStatus(String id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/billing/$id/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Order.fromJson(data['data']);
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update status tagihan');
  }

  // ==================== DASHBOARD ====================
  Future<DashboardStats> getDashboardStats() async {
    final response = await http.get(Uri.parse('$baseUrl/orders/stats/dashboard'), headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return DashboardStats.fromJson(data['data']);
      }
    }
    throw Exception('Gagal mengambil statistik dashboard');
  }

  // ==================== UANG JALAN ====================
  Future<Map<String, dynamic>> calculateUangJalan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/uang-jalan/calculate'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'] ?? {};
      }
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal menghitung uang jalan');
  }
}
