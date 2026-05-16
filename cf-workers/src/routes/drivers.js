import { Hono } from 'hono';

const app = new Hono();

// GET /api/drivers
app.get('/', async (c) => {
  try {
    const { status } = c.req.query();
    const drivers = await c.env.db.getAllDrivers(status);
    return c.json({ success: true, count: drivers.length, data: drivers });
  } catch (error) {
    console.error('Error fetching drivers:', error);
    return c.json({ success: false, error: 'Gagal mengambil data sopir' }, 500);
  }
});

// GET /api/drivers/available/list
app.get('/available/list', async (c) => {
  try {
    const drivers = await c.env.db.getAvailableDrivers();
    return c.json({ success: true, count: drivers.length, data: drivers });
  } catch (error) {
    console.error('Error fetching available drivers:', error);
    return c.json({ success: false, error: 'Gagal mengambil data sopir tersedia' }, 500);
  }
});

// GET /api/drivers/:id
app.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const driver = await c.env.db.getDriver(id);
    if (!driver) {
      return c.json({ success: false, error: 'Sopir tidak ditemukan' }, 404);
    }
    return c.json({ success: true, data: driver });
  } catch (error) {
    console.error('Error fetching driver:', error);
    return c.json({ success: false, error: 'Gagal mengambil data sopir' }, 500);
  }
});

// POST /api/drivers
app.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { nama, telepon, nopol_truck, armada } = body;

    if (!nama) {
      return c.json({ success: false, error: 'Nama sopir wajib diisi' }, 400);
    }

    const newDriver = await c.env.db.createDriver({
      nama,
      telepon: telepon || '',
      nopol_truck: nopol_truck || '',
      armada: armada || 'CDD'
    });

    return c.json({ success: true, message: 'Sopir berhasil ditambahkan', data: newDriver }, 201);
  } catch (error) {
    console.error('Error creating driver:', error);
    return c.json({ success: false, error: 'Gagal menambahkan sopir' }, 500);
  }
});

// PUT /api/drivers/:id
app.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const existing = await c.env.db.getDriver(id);
    
    if (!existing) {
      return c.json({ success: false, error: 'Sopir tidak ditemukan' }, 404);
    }

    const updated = await c.env.db.updateDriver(id, body);
    return c.json({ success: true, message: 'Sopir berhasil diupdate', data: updated });
  } catch (error) {
    console.error('Error updating driver:', error);
    return c.json({ success: false, error: 'Gagal mengupdate sopir' }, 500);
  }
});

// DELETE /api/drivers/:id
app.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const deleted = await c.env.db.deleteDriver(id);
    
    if (!deleted) {
      return c.json({ success: false, error: 'Sopir tidak ditemukan' }, 404);
    }

    return c.json({ success: true, message: 'Sopir berhasil dihapus' });
  } catch (error) {
    console.error('Error deleting driver:', error);
    return c.json({ success: false, error: 'Gagal menghapus sopir' }, 500);
  }
});

// ==================== DRIVER LOGS ====================

// GET /api/drivers/logs/all
app.get('/logs/all', async (c) => {
  try {
    const { order_id } = c.req.query();
    const logs = await c.env.db.getDriverLogs(order_id);
    return c.json({ success: true, count: logs.length, data: logs });
  } catch (error) {
    console.error('Error fetching driver logs:', error);
    return c.json({ success: false, error: 'Gagal mengambil log sopir' }, 500);
  }
});

// POST /api/drivers/logs
app.post('/logs', async (c) => {
  try {
    const body = await c.req.json();
    const { order_id, driver_id, driver_nama, status_update, foto_url, catatan } = body;

    if (!order_id || !driver_nama || !status_update) {
      return c.json({ success: false, error: 'Order ID, nama driver, dan status update wajib diisi' }, 400);
    }

    const validStatuses = ['MUAT', 'JALAN', 'SAMPAI', 'BONGKAR'];
    if (!validStatuses.includes(status_update)) {
      return c.json({ success: false, error: 'Status update tidak valid. Pilihan: MUAT, JALAN, SAMPAI, BONGKAR' }, 400);
    }

    const updatedOrder = await c.env.db.createDriverLog({
      order_id: order_id.toUpperCase(),
      driver_id,
      driver_nama,
      status_update,
      foto_url: foto_url || '',
      catatan: catatan || ''
    });

    return c.json({ success: true, message: 'Update berhasil disimpan', data: updatedOrder }, 201);
  } catch (error) {
    console.error('Error creating driver log:', error);
    return c.json({ success: false, error: 'Gagal menyimpan update' }, 500);
  }
});

export default app;
