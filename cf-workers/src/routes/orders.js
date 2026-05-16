import { Hono } from 'hono';

const app = new Hono();

// GET /api/orders
app.get('/', async (c) => {
  try {
    const { status, search } = c.req.query();
    const orders = await c.env.db.getAllOrders({ status, search });
    return c.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    console.error('Error fetching orders:', error);
    return c.json({ success: false, error: 'Gagal mengambil data order' }, 500);
  }
});

// GET /api/orders/active-for-tracking
app.get('/active-for-tracking', async (c) => {
  try {
    const orders = await c.env.db.query(`
      SELECT o.*, 
        c.nama as customer_nama,
        c.telepon as customer_telepon,
        d.nama as driver_nama,
        d.telepon as driver_telepon,
        d.nopol_truck
      FROM orders o
      LEFT JOIN customers c ON o.customer_id = c.id
      LEFT JOIN drivers d ON o.driver_id = d.id
      WHERE o.status != 'SELESAI'
      ORDER BY o.created_at DESC
    `);
    
    return c.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    console.error('Error fetching active orders:', error);
    return c.json({ success: false, error: 'Gagal mengambil data order aktif' }, 500);
  }
});

// GET /api/orders/active-for-driver
app.get('/active-for-driver', async (c) => {
  try {
    const orders = await c.env.db.query(`
      SELECT o.id, o.titik_a, o.titik_b, o.status, o.driver_nama, o.customer_nama
      FROM orders o
      WHERE o.status != 'SELESAI'
      ORDER BY o.created_at DESC
    `);
    
    return c.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    console.error('Error fetching active orders for driver:', error);
    return c.json({ success: false, error: 'Gagal mengambil data order aktif' }, 500);
  }
});

// GET /api/orders/:id
app.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const order = await c.env.db.getOrder(id);
    if (!order) {
      return c.json({ success: false, error: 'Order tidak ditemukan' }, 404);
    }
    return c.json({ success: true, data: order });
  } catch (error) {
    console.error('Error fetching order:', error);
    return c.json({ success: false, error: 'Gagal mengambil data order' }, 500);
  }
});

// POST /api/orders
app.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const {
      id, customer_id, customer_nama, titik_a, titik_b, jenis_barang,
      driver_id, driver_nama, jarak_km, konsumsi_bbm, harga_bbm,
      biaya_tol, biaya_makan, total_uang_jalan, nilai_tagihan, lat_a, lng_a, lat, lng, nopol_truck
    } = body;

    if (!id || !customer_nama || !titik_a || !titik_b) {
      return c.json({ success: false, error: 'ID, nama customer, titik A, dan titik B wajib diisi' }, 400);
    }

    const newOrder = await c.env.db.createOrder({
      id, customer_id, customer_nama, titik_a, titik_b, jenis_barang,
      driver_id, driver_nama, jarak_km, konsumsi_bbm, harga_bbm,
      biaya_tol, biaya_makan, total_uang_jalan, nilai_tagihan, lat_a, lng_a, lat, lng, nopol_truck
    });

    return c.json({ success: true, message: 'Order berhasil dibuat', data: newOrder }, 201);
  } catch (error) {
    console.error('Error creating order:', error);
    return c.json({ success: false, error: 'Gagal membuat order' }, 500);
  }
});

// PUT /api/orders/:id
app.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const existing = await c.env.db.getOrder(id);
    
    if (!existing) {
      return c.json({ success: false, error: 'Order tidak ditemukan' }, 404);
    }

    const updated = await c.env.db.updateOrder(id, body);
    return c.json({ success: true, message: 'Order berhasil diupdate', data: updated });
  } catch (error) {
    console.error('Error updating order:', error);
    return c.json({ success: false, error: 'Gagal mengupdate order' }, 500);
  }
});

// PATCH /api/orders/:id/status
app.patch('/:id/status', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const { status, keterangan } = body;

    if (!status) {
      return c.json({ success: false, error: 'Status wajib diisi' }, 400);
    }

    const updated = await c.env.db.updateOrderStatus(id, status, keterangan || '');
    return c.json({ success: true, message: 'Status order berhasil diupdate', data: updated });
  } catch (error) {
    console.error('Error updating order status:', error);
    return c.json({ success: false, error: 'Gagal mengupdate status order' }, 500);
  }
});

// PATCH /api/orders/:id/assign-driver
app.patch('/:id/assign-driver', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const { driver_id, driver_nama } = body;

    if (!driver_id || !driver_nama) {
      return c.json({ success: false, error: 'Driver ID dan nama driver wajib diisi' }, 400);
    }

    const updated = await c.env.db.assignDriver(id, driver_id, driver_nama);
    return c.json({ success: true, message: 'Driver berhasil diassign', data: updated });
  } catch (error) {
    console.error('Error assigning driver:', error);
    return c.json({ success: false, error: 'Gagal assign driver' }, 500);
  }
});

// PATCH /api/orders/:id/pod
app.patch('/:id/pod', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const { pod_surat_jalan, pod_barang_sampai, pod_notes } = body;

    const updated = await c.env.db.uploadPOD(id, { pod_surat_jalan, pod_barang_sampai, pod_notes });
    return c.json({ success: true, message: 'POD berhasil diupload', data: updated });
  } catch (error) {
    console.error('Error uploading POD:', error);
    return c.json({ success: false, error: 'Gagal upload POD' }, 500);
  }
});

// DELETE /api/orders/:id
app.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const deleted = await c.env.db.deleteOrder(id);
    
    if (!deleted) {
      return c.json({ success: false, error: 'Order tidak ditemukan' }, 404);
    }

    return c.json({ success: true, message: 'Order berhasil dihapus' });
  } catch (error) {
    console.error('Error deleting order:', error);
    return c.json({ success: false, error: 'Gagal menghapus order' }, 500);
  }
});

export default app;
