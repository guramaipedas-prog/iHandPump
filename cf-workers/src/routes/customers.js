import { Hono } from 'hono';

const app = new Hono();

// GET /api/customers
app.get('/', async (c) => {
  try {
    const customers = await c.env.db.getAllCustomers();
    return c.json({ success: true, count: customers.length, data: customers });
  } catch (error) {
    console.error('Error fetching customers:', error);
    return c.json({ success: false, error: 'Gagal mengambil data pelanggan' }, 500);
  }
});

// GET /api/customers/:id
app.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const customer = await c.env.db.getCustomer(id);
    if (!customer) {
      return c.json({ success: false, error: 'Pelanggan tidak ditemukan' }, 404);
    }
    return c.json({ success: true, data: customer });
  } catch (error) {
    console.error('Error fetching customer:', error);
    return c.json({ success: false, error: 'Gagal mengambil data pelanggan' }, 500);
  }
});

// POST /api/customers
app.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { nama, telepon, alamat } = body;

    if (!nama) {
      return c.json({ success: false, error: 'Nama pelanggan wajib diisi' }, 400);
    }

    const newCustomer = await c.env.db.createCustomer({ nama, telepon, alamat });
    return c.json({ success: true, message: 'Pelanggan berhasil ditambahkan', data: newCustomer }, 201);
  } catch (error) {
    console.error('Error creating customer:', error);
    return c.json({ success: false, error: 'Gagal menambahkan pelanggan' }, 500);
  }
});

// PUT /api/customers/:id
app.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const existing = await c.env.db.getCustomer(id);
    
    if (!existing) {
      return c.json({ success: false, error: 'Pelanggan tidak ditemukan' }, 404);
    }

    const updated = await c.env.db.updateCustomer(id, body);
    return c.json({ success: true, message: 'Pelanggan berhasil diupdate', data: updated });
  } catch (error) {
    console.error('Error updating customer:', error);
    return c.json({ success: false, error: 'Gagal mengupdate pelanggan' }, 500);
  }
});

// DELETE /api/customers/:id
app.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const deleted = await c.env.db.deleteCustomer(id);
    
    if (!deleted) {
      return c.json({ success: false, error: 'Pelanggan tidak ditemukan' }, 404);
    }

    return c.json({ success: true, message: 'Pelanggan berhasil dihapus' });
  } catch (error) {
    console.error('Error deleting customer:', error);
    return c.json({ success: false, error: 'Gagal menghapus pelanggan' }, 500);
  }
});

export default app;
