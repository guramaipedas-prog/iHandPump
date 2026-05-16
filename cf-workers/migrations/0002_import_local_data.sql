-- Import from local SQLite (mvp.db)
PRAGMA foreign_keys = OFF;

INSERT OR REPLACE INTO "uang_jalan_templates" ("id", "nama_rute", "titik_a", "titik_b", "jarak_km", "konsumsi_bbm", "harga_bbm", "biaya_tol", "biaya_makan", "created_at") VALUES
(1, 'Surabaya - Jakarta', 'Surabaya', 'Jakarta', 800, 5, 10000, 350000, 150000, '2026-04-08 13:44:28'),
(2, 'Surabaya - Bandung', 'Surabaya', 'Bandung', 750, 5, 10000, 300000, 150000, '2026-04-08 13:44:28'),
(3, 'Surabaya - Malang', 'Surabaya', 'Malang', 100, 5, 10000, 50000, 50000, '2026-04-08 13:44:28'),
(4, 'Surabaya - Denpasar', 'Surabaya', 'Denpasar', 450, 5, 10000, 200000, 100000, '2026-04-08 13:44:28');

INSERT OR REPLACE INTO "drivers" ("id", "nama", "telepon", "nopol_truck", "armada", "status", "created_at") VALUES
(1, 'Budi Santoso', '081234567890', 'L 1234 XY', 'CDD', 'AKTIF', '2026-04-08 13:44:28'),
(2, 'Ahmad Yani', '081234567891', 'L 5678 AB', 'CDE', 'AKTIF', '2026-04-08 13:44:28'),
(3, 'Slamet Riyadi', '081234567892', 'L 9012 CD', 'CDD', 'AKTIF', '2026-04-08 13:44:28');

INSERT OR REPLACE INTO "orders" ("id", "tanggal", "customer_id", "customer_nama", "titik_a", "titik_b", "jenis_barang", "driver_id", "driver_nama", "status", "jarak_km", "konsumsi_bbm", "harga_bbm", "biaya_tol", "biaya_makan", "total_uang_jalan", "pod_surat_jalan", "pod_barang_sampai", "pod_notes", "pod_uploaded_at", "nilai_tagihan", "status_tagihan", "tanggal_lunas", "lokasi_terakhir", "lat", "lng", "created_at", "updated_at", "lat_a", "lng_a", "nopol_truck") VALUES
('ORD-001', '2026-04-06 13:44:28', 1, 'PT Maju Jaya', 'Surabaya', 'Jakarta', 'Elektronik', 1, 'Budi Santoso', 'SELESAI', 800, 5, 10000, 350000, 150000, 1950000, NULL, NULL, NULL, NULL, 5000000, 'LUNAS', '2026-04-09T11:08:25.638Z', 'Jakarta', -7.2575, 112.7521, '2026-04-08 13:44:28', '2026-04-09 11:08:25', -7.2575, 112.7521, NULL),
('ORD-002', '2026-04-07 13:44:28', 2, 'CV Sukses Abadi', 'Surabaya', 'Bandung', 'Textile', 2, 'Ahmad Yani', 'SELESAI', 750, 5, 10000, 300000, 150000, 1800000, NULL, NULL, NULL, NULL, 4500000, 'BELUM', NULL, 'Cirebon', -7.2575, 112.7521, '2026-04-08 13:44:28', '2026-04-09 11:08:18', -7.2575, 112.7521, NULL),
('ORD-003', '2026-04-08 13:44:28', 3, 'Toko Sejahtera', 'Surabaya', 'Malang', 'Semen', 3, 'Slamet Riyadi', 'BONGKAR', 100, 5, 10000, 50000, 50000, 250000, NULL, NULL, NULL, NULL, 1200000, 'BELUM', NULL, 'Surabaya', -7.2575, 112.7521, '2026-04-08 13:44:28', '2026-04-09 11:08:07', -7.2575, 112.7521, NULL),
('ORD-004', '2026-04-08 13:44:28', 1, 'PT Maju Jaya', 'Surabaya', 'Denpasar', 'Plastik', NULL, NULL, 'SELESAI', 450, 5, 10000, 200000, 100000, 1100000, NULL, NULL, NULL, NULL, 3500000, 'LUNAS', '2026-04-09T12:33:05.536Z', NULL, -7.2575, 112.7521, '2026-04-08 13:44:28', '2026-04-09 12:33:05', -7.2575, 112.7521, NULL),
('ORD5', '2026-04-09 11:07:37', 4, 'SINGEL', 'KLATEN', 'SURABAYA', 'PLASTIK', 1, 'Budi Santoso', 'JALAN', 300, 10, 10000, 0, 300000, 600000, NULL, NULL, NULL, NULL, 1700000, 'BELUM', NULL, NULL, -7.2575, 112.7521, '2026-04-09 11:07:37', '2026-04-09 11:07:50', -7.2575, 112.7521, NULL),
('TEST-001', '2026-05-07 14:49:41', NULL, 'Test Customer', 'A', 'B', 'Test', NULL, NULL, 'MUAT', 100, 5, 10000, 0, 0, 200000, NULL, NULL, NULL, NULL, 0, 'BELUM', NULL, 'B', -7.2575, 112.7521, '2026-05-07 14:49:41', '2026-05-07 14:49:41', -7.2575, 112.7521, NULL);

INSERT OR REPLACE INTO "driver_logs" ("id", "order_id", "driver_id", "driver_nama", "status_update", "foto_url", "catatan", "created_at") VALUES
(1, 'TEST-001', NULL, 'Budi Test', 'MUAT', '', 'Test log', '2026-05-07 14:49:41');

INSERT OR REPLACE INTO "order_history" ("id", "order_id", "status", "keterangan", "created_by", "created_at") VALUES
(1, 'ORD5', 'DIJADWALKAN', 'Order dibuat', 'SYSTEM', '2026-04-09 11:07:37'),
(2, 'ORD5', 'JALAN', 'Status berubah dari DIJADWALKAN ke JALAN', 'SYSTEM', '2026-04-09 11:07:50'),
(3, 'ORD5', 'JALAN', '', 'Admin', '2026-04-09 11:07:50'),
(4, 'ORD-003', 'BONGKAR', 'Status berubah dari MUAT ke BONGKAR', 'SYSTEM', '2026-04-09 11:08:07'),
(5, 'ORD-003', 'BONGKAR', '', 'Admin', '2026-04-09 11:08:07'),
(6, 'ORD-004', 'JALAN', 'Status berubah dari MENUNGGU ke JALAN', 'SYSTEM', '2026-04-09 11:08:13'),
(7, 'ORD-004', 'JALAN', '', 'Admin', '2026-04-09 11:08:13'),
(8, 'ORD-002', 'SELESAI', 'Status berubah dari JALAN ke SELESAI', 'SYSTEM', '2026-04-09 11:08:18'),
(9, 'ORD-002', 'SELESAI', '', 'Admin', '2026-04-09 11:08:18'),
(10, 'ORD-004', 'SELESAI', 'Status berubah dari JALAN ke SELESAI', 'SYSTEM', '2026-04-09 12:32:39'),
(11, 'ORD-004', 'SELESAI', '', 'Admin', '2026-04-09 12:32:39'),
(12, 'TEST-001', 'MENUNGGU', 'Order dibuat', 'SYSTEM', '2026-05-07 14:49:41'),
(13, 'TEST-001', 'MUAT', 'Status berubah dari MENUNGGU ke MUAT', 'SYSTEM', '2026-05-07 14:49:41'),
(14, 'TEST-001', 'MUAT', 'Test log', 'Budi Test', '2026-05-07 14:49:41');

INSERT OR REPLACE INTO "fuel_prices" ("jenis", "nama", "harga", "satuan", "updated_at") VALUES
('BIOSOLAR', 'Pertamina Dex / Bio Solar', 15000, 'liter', '2026-05-09 09:08:47'),
('SOLAR', 'Solar Industri', 7200, 'liter', '2026-05-09 07:02:52');

INSERT OR REPLACE INTO "customers" ("id", "nama", "telepon", "alamat", "email", "created_at") VALUES
(1, 'PT Maju Jaya', '031-1234567', 'Jl. Raya Surabaya No. 1', NULL, '2026-04-08 13:44:28'),
(2, 'CV Sukses Abadi', '031-7654321', 'Jl. Raya Malang No. 5', NULL, '2026-04-08 13:44:28'),
(3, 'Toko Sejahtera', '081333444555', 'Jl. Raya Sidoarjo No. 10', NULL, '2026-04-08 13:44:28'),
(4, 'SINGEL', '08123456', 'KLATEN', 'singel@gmail.com', '2026-04-09 11:04:33');

PRAGMA foreign_keys = ON;
