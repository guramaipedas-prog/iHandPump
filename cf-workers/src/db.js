/**
 * D1 Database Adapter untuk Cloudflare Workers
 * Compatible dengan API DatabaseMVP (SQLite style)
 */

class DatabaseD1 {
  constructor(db) {
    this.db = db;
  }

  // Generic query (SELECT all)
  async query(sql, params = []) {
    const stmt = this.db.prepare(sql).bind(...params);
    const result = await stmt.all();
    return result.results || [];
  }

  // Single row query
  async get(sql, params = []) {
    const stmt = this.db.prepare(sql).bind(...params);
    const result = await stmt.first();
    return result || null;
  }

  // Run (INSERT/UPDATE/DELETE)
  async run(sql, params = []) {
    const stmt = this.db.prepare(sql).bind(...params);
    const result = await stmt.run();
    return {
      id: result.meta?.last_row_id,
      changes: result.meta?.changes
    };
  }

  // ==================== CUSTOMERS ====================
  async getAllCustomers() {
    return await this.query('SELECT * FROM customers ORDER BY nama ASC');
  }

  async getCustomer(id) {
    return await this.get('SELECT * FROM customers WHERE id = ?', [id]);
  }

  async createCustomer({ nama, telepon, alamat }) {
    const result = await this.run(
      'INSERT INTO customers (nama, telepon, alamat) VALUES (?, ?, ?)',
      [nama, telepon || '', alamat || '']
    );
    return await this.getCustomer(result.id);
  }

  async updateCustomer(id, { nama, telepon, alamat }) {
    await this.run(
      'UPDATE customers SET nama = ?, telepon = ?, alamat = ? WHERE id = ?',
      [nama, telepon || '', alamat || '', id]
    );
    return await this.getCustomer(id);
  }

  async deleteCustomer(id) {
    const result = await this.run('DELETE FROM customers WHERE id = ?', [id]);
    return result.changes > 0;
  }

  // ==================== DRIVERS ====================
  async getAllDrivers(status = null) {
    let sql = 'SELECT * FROM drivers';
    const params = [];
    if (status) {
      sql += ' WHERE status = ?';
      params.push(status);
    }
    sql += ' ORDER BY nama ASC';
    return await this.query(sql, params);
  }

  async getDriver(id) {
    return await this.get('SELECT * FROM drivers WHERE id = ?', [id]);
  }

  async getAvailableDrivers() {
    return await this.query(
      `SELECT * FROM drivers WHERE status = 'AKTIF' 
       AND id NOT IN (
         SELECT driver_id FROM orders 
         WHERE status IN ('DIJADWALKAN', 'MUAT', 'JALAN', 'BONGKAR') 
         AND driver_id IS NOT NULL
       ) ORDER BY nama ASC`
    );
  }

  async createDriver({ nama, telepon, nopol_truck, armada }) {
    const result = await this.run(
      'INSERT INTO drivers (nama, telepon, nopol_truck, armada) VALUES (?, ?, ?, ?)',
      [nama, telepon || '', nopol_truck || '', armada || 'CDD']
    );
    return await this.getDriver(result.id);
  }

  async updateDriver(id, { nama, telepon, nopol_truck, armada, status }) {
    await this.run(
      'UPDATE drivers SET nama = ?, telepon = ?, nopol_truck = ?, armada = ?, status = ? WHERE id = ?',
      [nama, telepon || '', nopol_truck || '', armada || 'CDD', status || 'AKTIF', id]
    );
    return await this.getDriver(id);
  }

  async deleteDriver(id) {
    const result = await this.run('DELETE FROM drivers WHERE id = ?', [id]);
    return result.changes > 0;
  }

  // ==================== ORDERS ====================
  async getAllOrders(filters = {}) {
    let sql = `
      SELECT o.*, 
        c.nama as customer_nama_display,
        c.telepon as customer_telepon
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
    `;
    const params = [];
    const conditions = [];

    if (filters.status) {
      conditions.push('o.status = ?');
      params.push(filters.status);
    }

    if (filters.status_tagihan) {
      conditions.push('o.status_tagihan = ?');
      params.push(filters.status_tagihan);
    }

    if (filters.driver_id) {
      conditions.push('o.driver_id = ?');
      params.push(filters.driver_id);
    }

    if (filters.search) {
      conditions.push('(o.id LIKE ? OR o.customer_nama LIKE ? OR o.driver_nama LIKE ?)');
      const searchPattern = `%${filters.search}%`;
      params.push(searchPattern, searchPattern, searchPattern);
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    sql += ' ORDER BY o.created_at DESC';
    return await this.query(sql, params);
  }

  async getOrder(id) {
    const order = await this.get(`
      SELECT o.*, 
        c.nama as customer_nama_display,
        c.telepon as customer_telepon,
        c.alamat as customer_alamat,
        COALESCE(o.nopol_truck, d.nopol_truck) as nopol_truck_display
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
      LEFT JOIN drivers d ON o.driver_id = d.id
      WHERE o.id = ?
    `, [id]);
    
    if (!order) return null;

    const history = await this.query(
      'SELECT * FROM order_history WHERE order_id = ? ORDER BY created_at DESC',
      [id]
    );

    const driverLogs = await this.query(
      'SELECT * FROM driver_logs WHERE order_id = ? ORDER BY created_at DESC',
      [id]
    );

    return { ...order, history, driverLogs };
  }

  async createOrder({
    id, customer_id, customer_nama, titik_a, titik_b, jenis_barang,
    driver_id, driver_nama, jarak_km, konsumsi_bbm, harga_bbm,
    biaya_tol, biaya_makan, total_uang_jalan, nilai_tagihan, lat_a, lng_a, lat, lng, nopol_truck
  }) {
    // Use provided total_uang_jalan if available, otherwise calculate
    let totalUangJalan = total_uang_jalan;
    if (totalUangJalan === undefined || totalUangJalan === null) {
      const bbmNeeded = (jarak_km || 0) / (konsumsi_bbm || 5);
      totalUangJalan = (bbmNeeded * (harga_bbm || 10000)) + (biaya_tol || 0) + (biaya_makan || 0);
    }

    await this.run(`
      INSERT INTO orders (
        id, customer_id, customer_nama, titik_a, titik_b, jenis_barang,
        driver_id, driver_nama, status, jarak_km, konsumsi_bbm, harga_bbm,
        biaya_tol, biaya_makan, total_uang_jalan, nilai_tagihan,
        lat_a, lng_a, lat, lng, lokasi_terakhir, nopol_truck
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      id.toUpperCase(), customer_id || null, customer_nama, titik_a, titik_b, jenis_barang || '',
      driver_id || null, driver_nama || '', driver_id ? 'DIJADWALKAN' : 'MENUNGGU',
      jarak_km || 0, konsumsi_bbm || 5, harga_bbm || 10000, biaya_tol || 0, biaya_makan || 0,
      totalUangJalan, nilai_tagihan || 0,
      lat_a ?? -7.2575, lng_a ?? 112.7521, lat ?? -7.2575, lng ?? 112.7521, titik_b, nopol_truck || ''
    ]);

    await this.run(
      'INSERT INTO order_history (order_id, status, keterangan, created_by) VALUES (?, ?, ?, ?)',
      [id.toUpperCase(), driver_id ? 'DIJADWALKAN' : 'MENUNGGU', 'Order dibuat', 'SYSTEM']
    );

    return await this.getOrder(id.toUpperCase());
  }

  async updateOrder(id, data) {
    const {
      customer_id, customer_nama, titik_a, titik_b, jenis_barang,
      driver_id, driver_nama, status, jarak_km, konsumsi_bbm, harga_bbm,
      biaya_tol, biaya_makan, nilai_tagihan, status_tagihan
    } = data;

    let totalUangJalan = null;
    if (jarak_km !== undefined && konsumsi_bbm !== undefined && harga_bbm !== undefined) {
      const bbmNeeded = jarak_km / konsumsi_bbm;
      totalUangJalan = (bbmNeeded * harga_bbm) + (biaya_tol || 0) + (biaya_makan || 0);
    }

    await this.run(`
      UPDATE orders SET
        customer_id = COALESCE(?, customer_id),
        customer_nama = COALESCE(?, customer_nama),
        titik_a = COALESCE(?, titik_a),
        titik_b = COALESCE(?, titik_b),
        jenis_barang = COALESCE(?, jenis_barang),
        driver_id = COALESCE(?, driver_id),
        driver_nama = COALESCE(?, driver_nama),
        status = COALESCE(?, status),
        jarak_km = COALESCE(?, jarak_km),
        konsumsi_bbm = COALESCE(?, konsumsi_bbm),
        harga_bbm = COALESCE(?, harga_bbm),
        biaya_tol = COALESCE(?, biaya_tol),
        biaya_makan = COALESCE(?, biaya_makan),
        total_uang_jalan = COALESCE(?, total_uang_jalan),
        nilai_tagihan = COALESCE(?, nilai_tagihan),
        status_tagihan = COALESCE(?, status_tagihan)
      WHERE id = ?
    `, [
      customer_id, customer_nama, titik_a, titik_b, jenis_barang,
      driver_id, driver_nama, status, jarak_km, konsumsi_bbm, harga_bbm,
      biaya_tol, biaya_makan, totalUangJalan, nilai_tagihan, status_tagihan, id
    ]);

    return await this.getOrder(id);
  }

  async updateOrderStatus(id, status, keterangan = '', createdBy = 'SYSTEM') {
    await this.run('UPDATE orders SET status = ? WHERE id = ?', [status, id]);
    
    await this.run(
      'INSERT INTO order_history (order_id, status, keterangan, created_by) VALUES (?, ?, ?, ?)',
      [id, status, keterangan, createdBy]
    );

    return await this.getOrder(id);
  }

  async assignDriver(id, driverId, driverNama) {
    const driver = await this.getDriver(driverId);
    const nopol = driver?.nopol_truck || '';

    await this.run(
      'UPDATE orders SET driver_id = ?, driver_nama = ?, nopol_truck = ?, status = ? WHERE id = ?',
      [driverId, driverNama, nopol, 'DIJADWALKAN', id]
    );

    await this.run(
      'INSERT INTO order_history (order_id, status, keterangan, created_by) VALUES (?, ?, ?, ?)',
      [id, 'DIJADWALKAN', `Driver ${driverNama} diassign`, 'SYSTEM']
    );

    return await this.getOrder(id);
  }

  async uploadPOD(id, { pod_surat_jalan, pod_barang_sampai, pod_notes }) {
    await this.run(`
      UPDATE orders SET
        pod_surat_jalan = COALESCE(?, pod_surat_jalan),
        pod_barang_sampai = COALESCE(?, pod_barang_sampai),
        pod_notes = ?,
        pod_uploaded_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `, [pod_surat_jalan, pod_barang_sampai, pod_notes || '', id]);

    return await this.getOrder(id);
  }

  async deleteOrder(id) {
    const result = await this.run('DELETE FROM orders WHERE id = ?', [id]);
    return result.changes > 0;
  }

  // ==================== DRIVER LOGS ====================
  async createDriverLog({ order_id, driver_id, driver_nama, status_update, foto_url, catatan }) {
    await this.run(`
      INSERT INTO driver_logs (order_id, driver_id, driver_nama, status_update, foto_url, catatan)
      VALUES (?, ?, ?, ?, ?, ?)
    `, [order_id, driver_id || null, driver_nama, status_update, foto_url || '', catatan || '']);

    let newStatus = status_update;
    if (status_update === 'SAMPAI') newStatus = 'BONGKAR';
    
    await this.updateOrderStatus(order_id, newStatus, catatan || `Update dari driver: ${status_update}`, driver_nama);

    return await this.getOrder(order_id);
  }

  async getDriverLogs(orderId = null) {
    if (orderId) {
      return await this.query(
        'SELECT * FROM driver_logs WHERE order_id = ? ORDER BY created_at DESC',
        [orderId]
      );
    }
    return await this.query('SELECT * FROM driver_logs ORDER BY created_at DESC LIMIT 100');
  }

  // ==================== BILLING ====================
  async getBillingList(status = null, month = null, year = null) {
    let sql = `
      SELECT o.*, 
        c.nama as customer_nama_display,
        c.telepon as customer_telepon
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
      WHERE o.status = 'SELESAI'
    `;
    const params = [];

    if (status) {
      sql += ' AND o.status_tagihan = ?';
      params.push(status);
    }

    if (month != null && year != null) {
      sql += " AND strftime('%m', o.tanggal) = ? AND strftime('%Y', o.tanggal) = ?";
      params.push(month.toString().padStart(2, '0'), year.toString());
    }

    sql += ' ORDER BY o.tanggal DESC';
    return await this.query(sql, params);
  }

  async getReadyForBilling() {
    return await this.query(`
      SELECT o.*, 
        c.nama as customer_nama_display,
        c.telepon as customer_telepon
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
      WHERE o.status = 'SELESAI' 
        AND (o.pod_surat_jalan IS NOT NULL OR o.pod_barang_sampai IS NOT NULL)
      ORDER BY o.tanggal DESC
    `);
  }

  async updateBillingStatus(id, status) {
    const tanggalLunas = status === 'LUNAS' ? new Date().toISOString() : null;
    
    await this.run(
      'UPDATE orders SET status_tagihan = ?, tanggal_lunas = ? WHERE id = ?',
      [status, tanggalLunas, id]
    );

    return await this.getOrder(id);
  }

  async getBillingStats({ month, year } = {}) {
    let whereClause = "WHERE status = 'SELESAI'";
    let params = [];
    
    if (month && year) {
      whereClause += " AND strftime('%m', tanggal) = ? AND strftime('%Y', tanggal) = ?";
      params = [month.toString().padStart(2, '0'), year.toString()];
    }

    return await this.get(`
      SELECT 
        COUNT(*) as total_tagihan,
        SUM(CASE WHEN status_tagihan = 'BELUM' THEN 1 ELSE 0 END) as belum_lunas,
        SUM(CASE WHEN status_tagihan = 'LUNAS' THEN 1 ELSE 0 END) as sudah_lunas,
        SUM(CASE WHEN status_tagihan = 'BELUM' THEN nilai_tagihan ELSE 0 END) as total_piutang,
        SUM(CASE WHEN status_tagihan = 'LUNAS' THEN nilai_tagihan ELSE 0 END) as total_terbayar
      FROM orders
      ${whereClause}
    `, params);
  }

  // ==================== UANG JALAN TEMPLATES ====================
  async getAllUangJalanTemplates() {
    return await this.query('SELECT * FROM uang_jalan_templates ORDER BY nama_rute ASC');
  }

  async getUangJalanTemplate(id) {
    return await this.get('SELECT * FROM uang_jalan_templates WHERE id = ?', [id]);
  }

  async calculateUangJalan({ jarak_km, konsumsi_bbm, harga_bbm, biaya_tol, biaya_makan }) {
    const bbmNeeded = jarak_km / (konsumsi_bbm || 5);
    const totalBbm = bbmNeeded * (harga_bbm || 10000);
    const total = totalBbm + (biaya_tol || 0) + (biaya_makan || 0);

    return {
      jarak_km,
      konsumsi_bbm: konsumsi_bbm || 5,
      harga_bbm: harga_bbm || 10000,
      bbm_needed: Math.round(bbmNeeded * 100) / 100,
      total_bbm: Math.round(totalBbm),
      biaya_tol: biaya_tol || 0,
      biaya_makan: biaya_makan || 0,
      total: Math.round(total)
    };
  }

  // ==================== FUEL PRICES ====================
  async getAllFuelPrices() {
    return await this.query('SELECT * FROM fuel_prices ORDER BY nama ASC');
  }

  async getFuelPrice(jenis) {
    return await this.get('SELECT * FROM fuel_prices WHERE jenis = ?', [jenis.toUpperCase()]);
  }

  async updateFuelPrice(jenis, harga) {
    await this.run(
      'UPDATE fuel_prices SET harga = ?, updated_at = CURRENT_TIMESTAMP WHERE jenis = ?',
      [harga, jenis.toUpperCase()]
    );
    return await this.getFuelPrice(jenis);
  }

  // ==================== STATS & DASHBOARD ====================
  async getDashboardStats({ month, year } = {}) {
    let whereClause = '';
    let params = [];
    
    if (month && year) {
      whereClause = "WHERE strftime('%m', tanggal) = ? AND strftime('%Y', tanggal) = ?";
      params = [month.toString().padStart(2, '0'), year.toString()];
    }

    const orderStats = await this.get(`
      SELECT 
        COUNT(*) as total_orders,
        SUM(CASE WHEN status = 'MENUNGGU' THEN 1 ELSE 0 END) as menunggu,
        SUM(CASE WHEN status = 'DIJADWALKAN' THEN 1 ELSE 0 END) as dijadwalkan,
        SUM(CASE WHEN status = 'MUAT' THEN 1 ELSE 0 END) as muat,
        SUM(CASE WHEN status = 'JALAN' THEN 1 ELSE 0 END) as jalan,
        SUM(CASE WHEN status = 'BONGKAR' THEN 1 ELSE 0 END) as bongkar,
        SUM(CASE WHEN status = 'SELESAI' THEN 1 ELSE 0 END) as selesai
      FROM orders
      ${whereClause}
    `, params);

    const billingStats = await this.getBillingStats({ month, year });

    const todayOrders = await this.get(`
      SELECT COUNT(*) as count FROM orders WHERE date(tanggal) = date('now')
    `);

    let activeDriverWhere = "WHERE status IN ('DIJADWALKAN', 'MUAT', 'JALAN', 'BONGKAR')";
    let activeDriverParams = [];
    if (month && year) {
      activeDriverWhere += " AND strftime('%m', tanggal) = ? AND strftime('%Y', tanggal) = ?";
      activeDriverParams = params;
    }
    const activeDrivers = await this.get(`
      SELECT COUNT(DISTINCT driver_id) as count 
      FROM orders 
      ${activeDriverWhere}
    `, activeDriverParams);

    return {
      orders: orderStats,
      billing: billingStats,
      today_orders: todayOrders?.count || 0,
      active_drivers: activeDrivers?.count || 0
    };
  }

  async getAvailablePeriods() {
    return await this.query(`
      SELECT 
        CAST(strftime('%m', tanggal) AS INTEGER) as month,
        CAST(strftime('%Y', tanggal) AS INTEGER) as year
      FROM orders
      GROUP BY strftime('%m', tanggal), strftime('%Y', tanggal)
      ORDER BY year DESC, month DESC
    `);
  }

  async getRecentOrders(limit = 10) {
    return await this.query(`
      SELECT o.*, c.nama as customer_nama_display
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
      ORDER BY o.created_at DESC
      LIMIT ?
    `, [limit]);
  }

  // ==================== LEGACY TRACKING ====================
  async getAllShipments() {
    return await this.query('SELECT * FROM shipments ORDER BY created_at DESC');
  }

  async getShipment(id) {
    return await this.get('SELECT * FROM shipments WHERE id = ?', [id]);
  }

  async getShipmentWithHistory(id) {
    const shipment = await this.getShipment(id);
    if (!shipment) return null;
    const history = await this.query(
      'SELECT * FROM shipment_history WHERE shipment_id = ? ORDER BY id ASC',
      [id]
    );
    return { ...shipment, history };
  }
}

export { DatabaseD1 };
