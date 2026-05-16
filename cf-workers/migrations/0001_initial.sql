-- =====================================================
-- D1 Migration 0001: MVP Schema + Legacy Tracking
-- Cloudflare D1 Database for iHandPump API
-- =====================================================

-- Tabel Customers (Data Pelanggan)
CREATE TABLE IF NOT EXISTS customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    telepon TEXT,
    alamat TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Drivers (Data Sopir)
CREATE TABLE IF NOT EXISTS drivers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    telepon TEXT,
    nopol_truck TEXT,
    armada TEXT,
    status TEXT DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'OFF', 'LIBUR')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Orders (Data Order/Pengiriman)
CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    tanggal DATETIME DEFAULT CURRENT_TIMESTAMP,
    customer_id INTEGER,
    customer_nama TEXT NOT NULL,
    titik_a TEXT NOT NULL,
    titik_b TEXT NOT NULL,
    jenis_barang TEXT,
    driver_id INTEGER,
    driver_nama TEXT,
    status TEXT DEFAULT 'MENUNGGU' CHECK (status IN (
        'MENUNGGU', 'DIJADWALKAN', 'MUAT', 'JALAN', 'BONGKAR', 'SELESAI'
    )),
    jarak_km REAL DEFAULT 0,
    konsumsi_bbm REAL DEFAULT 0,
    harga_bbm REAL DEFAULT 0,
    biaya_tol REAL DEFAULT 0,
    biaya_makan REAL DEFAULT 0,
    total_uang_jalan REAL DEFAULT 0,
    pod_surat_jalan TEXT,
    pod_barang_sampai TEXT,
    pod_notes TEXT,
    pod_uploaded_at DATETIME,
    nilai_tagihan REAL DEFAULT 0,
    status_tagihan TEXT DEFAULT 'BELUM' CHECK (status_tagihan IN ('BELUM', 'LUNAS')),
    tanggal_lunas DATETIME,
    lokasi_terakhir TEXT,
    lat_a REAL DEFAULT -7.2575,
    lng_a REAL DEFAULT 112.7521,
    lat REAL DEFAULT -7.2575,
    lng REAL DEFAULT 112.7521,
    nopol_truck TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL
);

-- Tabel Driver Logs
CREATE TABLE IF NOT EXISTS driver_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id TEXT NOT NULL,
    driver_id INTEGER,
    driver_nama TEXT NOT NULL,
    status_update TEXT NOT NULL CHECK (status_update IN ('MUAT', 'JALAN', 'SAMPAI', 'BONGKAR')),
    foto_url TEXT,
    catatan TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL
);

-- Tabel Order History
CREATE TABLE IF NOT EXISTS order_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id TEXT NOT NULL,
    status TEXT NOT NULL,
    keterangan TEXT,
    created_by TEXT DEFAULT 'SYSTEM',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Tabel Uang Jalan Templates
CREATE TABLE IF NOT EXISTS uang_jalan_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_rute TEXT NOT NULL,
    titik_a TEXT NOT NULL,
    titik_b TEXT NOT NULL,
    jarak_km REAL DEFAULT 0,
    konsumsi_bbm REAL DEFAULT 0,
    harga_bbm REAL DEFAULT 0,
    biaya_tol REAL DEFAULT 0,
    biaya_makan REAL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Fuel Prices
CREATE TABLE IF NOT EXISTS fuel_prices (
    jenis TEXT PRIMARY KEY,
    nama TEXT NOT NULL,
    harga REAL NOT NULL DEFAULT 0,
    satuan TEXT DEFAULT 'liter',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Legacy: Tabel Shipments
CREATE TABLE IF NOT EXISTS shipments (
    id TEXT PRIMARY KEY,
    pengirim TEXT NOT NULL,
    wa TEXT,
    barang TEXT,
    asal TEXT,
    tujuan TEXT,
    armada TEXT,
    nopol TEXT,
    driver TEXT,
    status TEXT DEFAULT 'on-the-way',
    lokasi TEXT,
    lat REAL DEFAULT 0,
    lng REAL DEFAULT 0,
    progress INTEGER DEFAULT 0,
    eta TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Legacy: Tabel Shipment History
CREATE TABLE IF NOT EXISTS shipment_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shipment_id TEXT NOT NULL,
    label TEXT NOT NULL,
    time TEXT,
    done INTEGER DEFAULT 0,
    active INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_driver ON orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_orders_tagihan ON orders(status_tagihan);
CREATE INDEX IF NOT EXISTS idx_orders_tanggal ON orders(tanggal);
CREATE INDEX IF NOT EXISTS idx_driver_logs_order ON driver_logs(order_id);
CREATE INDEX IF NOT EXISTS idx_order_history_order ON order_history(order_id);

-- Seed Data: Fuel Prices
INSERT OR IGNORE INTO fuel_prices (jenis, nama, harga, satuan) VALUES 
('BIOSOLAR', 'Pertamina Dex / Bio Solar', 6800, 'liter'),
('SOLAR', 'Solar Industri', 7200, 'liter');

-- Seed Data: Drivers
INSERT OR IGNORE INTO drivers (id, nama, telepon, nopol_truck, armada, status) VALUES 
(1, 'Budi Santoso', '081234567890', 'L 1234 XY', 'CDD', 'AKTIF'),
(2, 'Ahmad Yani', '081234567891', 'L 5678 AB', 'CDE', 'AKTIF'),
(3, 'Slamet Riyadi', '081234567892', 'L 9012 CD', 'CDD', 'AKTIF');

-- Seed Data: Customers
INSERT OR IGNORE INTO customers (id, nama, telepon, alamat) VALUES 
(1, 'PT Maju Jaya', '031-1234567', 'Jl. Raya Surabaya No. 1'),
(2, 'CV Sukses Abadi', '031-7654321', 'Jl. Raya Malang No. 5'),
(3, 'Toko Sejahtera', '081333444555', 'Jl. Raya Sidoarjo No. 10');

-- Seed Data: Uang Jalan Templates
INSERT OR IGNORE INTO uang_jalan_templates (id, nama_rute, titik_a, titik_b, jarak_km, konsumsi_bbm, harga_bbm, biaya_tol, biaya_makan) VALUES 
(1, 'Surabaya - Jakarta', 'Surabaya', 'Jakarta', 800, 5, 10000, 350000, 150000),
(2, 'Surabaya - Bandung', 'Surabaya', 'Bandung', 750, 5, 10000, 300000, 150000),
(3, 'Surabaya - Malang', 'Surabaya', 'Malang', 100, 5, 10000, 50000, 50000),
(4, 'Surabaya - Denpasar', 'Surabaya', 'Denpasar', 450, 5, 10000, 200000, 100000);
