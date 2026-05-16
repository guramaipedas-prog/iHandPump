import { Hono } from 'hono';

const app = new Hono();

// GET /api/billing
app.get('/', async (c) => {
  try {
    const { status, month, year } = c.req.query();
    const billing = await c.env.db.getBillingList(
      status || null,
      month ? parseInt(month) : null,
      year ? parseInt(year) : null
    );
    return c.json({ success: true, count: billing.length, data: billing });
  } catch (error) {
    console.error('Error fetching billing:', error);
    return c.json({ success: false, error: 'Gagal mengambil data tagihan' }, 500);
  }
});

// GET /api/billing/stats
app.get('/stats', async (c) => {
  try {
    const { month, year } = c.req.query();
    const stats = await c.env.db.getBillingStats({
      month: month ? parseInt(month) : null,
      year: year ? parseInt(year) : null
    });
    return c.json({ success: true, data: stats });
  } catch (error) {
    console.error('Error fetching billing stats:', error);
    return c.json({ success: false, error: 'Gagal mengambil statistik tagihan' }, 500);
  }
});

// GET /api/billing/ready/list
app.get('/ready/list', async (c) => {
  try {
    const orders = await c.env.db.getReadyForBilling();
    return c.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    console.error('Error fetching ready for billing:', error);
    return c.json({ success: false, error: 'Gagal mengambil data siap ditagih' }, 500);
  }
});

// PATCH /api/billing/:id/status
app.patch('/:id/status', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const { status } = body;

    if (!status || !['BELUM', 'LUNAS'].includes(status)) {
      return c.json({ success: false, error: 'Status tidak valid. Pilihan: BELUM, LUNAS' }, 400);
    }

    const updated = await c.env.db.updateBillingStatus(id, status);
    return c.json({ success: true, message: 'Status tagihan berhasil diupdate', data: updated });
  } catch (error) {
    console.error('Error updating billing status:', error);
    return c.json({ success: false, error: 'Gagal mengupdate status tagihan' }, 500);
  }
});

export default app;
