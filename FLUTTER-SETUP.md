# 🚀 Setup Aplikasi Flutter Native - Ekspedisi MVP

Aplikasi Flutter native sudah dibuat di folder `ekspedisi_app/`. Berikut panduan lengkap untuk menjalankan dan build aplikasi.

## 📁 Struktur Project Flutter

```
ekspedisi_app/
├── android/              # Android platform code
├── lib/
│   ├── main.dart         # Entry point aplikasi
│   ├── models/           # Data models (Order, Driver, Customer, Shipment)
│   ├── services/         # API Service untuk komunikasi dengan backend
│   ├── providers/        # State management (Provider)
│   ├── screens/          # UI Screens
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── tracking_screen.dart
│   │   ├── driver_update_screen.dart
│   │   ├── customers_screen.dart
│   │   ├── drivers_screen.dart
│   │   └── billing_screen.dart
│   ├── widgets/          # Reusable widgets
│   └── theme/
│       └── app_theme.dart
├── pubspec.yaml
└── ...
```

## ⚡ Quick Start

### 1. Pastikan Backend Berjalan

```bash
cd backend
npm start
```

Backend harus berjalan di `http://localhost:3000`

### 2. Jalankan Aplikasi Flutter

**Untuk Android Emulator:**
```bash
cd ekspedisi_app
flutter run
```

**Untuk device fisik (Android):**
1. Hubungkan device via USB
2. Aktifkan USB Debugging di developer options
3. Jalankan:
```bash
flutter run
```

### 3. Build APK

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

APK akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

## 🔧 Konfigurasi API URL

Edit file `lib/services/api_service.dart` dan sesuaikan `baseUrl`:

```dart
String baseUrl = 'http://10.0.2.2:3000/api';  // Android Emulator
// String baseUrl = 'http://localhost:3000/api';  // iOS Simulator
// String baseUrl = 'https://your-domain.com/api';  // Production
```

| Environment | URL |
|-------------|-----|
| Android Emulator | `http://10.0.2.2:3000/api` |
| iOS Simulator | `http://localhost:3000/api` |
| Device Fisik (same WiFi) | `http://YOUR_PC_IP:3000/api` |
| Production | `https://your-domain.com/api` |

## 📱 Fitur Aplikasi

### Dashboard
- Statistik orders (total, jalan, selesai, piutang)
- Status breakdown
- Quick actions ke menu lain

### Orders
- List semua orders dengan filter status
- Tambah order baru
- Update status order
- Hapus order

### Tracking
- Cek resi pengiriman
- Peta dengan posisi truk (OpenStreetMap)
- Detail shipment

### Update Sopir
- Form update status perjalanan
- Pilihan status: MUAT, JALAN, SAMPAI, BONGKAR
- Upload foto dari kamera
- Kirim log ke admin

### Customers & Drivers
- List customers dan drivers
- Tambah/hapus data

### Penagihan
- List tagihan
- Update status lunas/belum
- Summary piutang vs lunas

## 🛠️ Setup Environment (Sudah Dilakukan)

Berikut adalah setup yang sudah dilakukan di folder ini:

1. **Flutter SDK** → `flutter_sdk/`
2. **Android SDK** → `android_sdk/`
3. **OpenJDK 17** → `java/jdk17/`

Untuk menggunakan tools ini, tambahkan ke PATH:

```powershell
$env:PATH = "E:\VSCODE\FUTTER\flutter_sdk\bin;$env:PATH"
$env:JAVA_HOME = "E:\VSCODE\FUTTER\java\jdk17"
$env:ANDROID_SDK_ROOT = "E:\VSCODE\FUTTER\android_sdk"
```

## 🐛 Troubleshooting

### Backend tidak terhubung
- Pastikan backend berjalan di port 3000
- Cek firewall tidak memblokir koneksi
- Untuk device fisik, gunakan IP address PC Anda

### Build error
```bash
flutter clean
flutter pub get
flutter build apk
```

### Gradle error
```bash
cd android
.\gradlew clean
```

### Permission denied (camera/location)
Pastikan `android/app/src/main/AndroidManifest.xml` sudah include permissions:
- `INTERNET`
- `CAMERA`
- `ACCESS_FINE_LOCATION`
- `READ_EXTERNAL_STORAGE`

## 📦 Dependencies Utama

| Package | Fungsi |
|---------|--------|
| `http` | HTTP requests ke backend API |
| `provider` | State management |
| `flutter_map` | Peta OpenStreetMap |
| `latlong2` | Koordinat geografis |
| `image_picker` | Akses kamera/galeri |
| `url_launcher` | Buka URL (WhatsApp) |
| `shared_preferences` | Local cache |
| `intl` | Format tanggal & mata uang |

## 🎨 Theme

Aplikasi menggunakan dark theme dengan warna oranye (#FF5A00) sebagai primary color, mengikuti design web app yang sudah ada.
