import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Service untuk mengambil harga BBM secara real-time dari Firebase Remote Config.
/// 
/// Setup Firebase:
/// 1. Buat project di https://console.firebase.google.com
/// 2. Register Android app dengan package name: com.example.ekspedisi_app
/// 3. Download google-services.json → taruh di android/app/
/// 4. Jalankan: flutterfire configure
class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfigService _instance = FirebaseRemoteConfigService._internal();
  factory FirebaseRemoteConfigService() => _instance;
  FirebaseRemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Inisialisasi Firebase & Remote Config
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults(const {
        'harga_biosolar': 6800.0,
        'harga_pertalite': 10000.0,
        'harga_pertamax': 12500.0,
      });

      await _remoteConfig.fetchAndActivate();
      _initialized = true;
    } catch (e) {
      print('Firebase Remote Config init error: $e');
      _initialized = false;
    }
  }

  /// Ambil harga Bio Solar (default: 6800)
  double getHargaBioSolar() {
    try {
      return _remoteConfig.getDouble('harga_biosolar');
    } catch (e) {
      return 6800.0;
    }
  }

  /// Ambil harga Pertalite (default: 10000)
  double getHargaPertalite() {
    try {
      return _remoteConfig.getDouble('harga_pertalite');
    } catch (e) {
      return 10000.0;
    }
  }

  /// Ambil harga Pertamax (default: 12500)
  double getHargaPertamax() {
    try {
      return _remoteConfig.getDouble('harga_pertamax');
    } catch (e) {
      return 12500.0;
    }
  }

  /// Ambil semua harga BBM
  Map<String, double> getAllFuelPrices() {
    return {
      'BIOSOLAR': getHargaBioSolar(),
      'PERTALITE': getHargaPertalite(),
      'PERTAMAX': getHargaPertamax(),
    };
  }

  /// Force fetch ulang dari Firebase (call setelah admin update harga)
  Future<bool> fetchLatest() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      return updated;
    } catch (e) {
      print('Fetch latest error: $e');
      return false;
    }
  }
}
