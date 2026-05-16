import { Hono } from 'hono';

const app = new Hono();

// GET /api/shipments
app.get('/', async (c) => {
  try {
    const shipments = await c.env.db.getAllShipments();
    return c.json({ success: true, count: shipments.length, data: shipments });
  } catch (error) {
    console.error('Error fetching shipments:', error);
    return c.json({ success: false, error: 'Gagal mengambil data pengiriman' }, 500);
  }
});

// GET /api/track/:resi
app.get('/:resi', async (c) => {
  try {
    const resi = c.req.param('resi');
    const shipment = await c.env.db.getShipmentWithHistory(resi);
    
    if (!shipment) {
      return c.json({ success: false, error: 'Nomor resi tidak ditemukan' }, 404);
    }
    
    return c.json({ success: true, data: shipment });
  } catch (error) {
    console.error('Error tracking shipment:', error);
    return c.json({ success: false, error: 'Gagal melacak pengiriman' }, 500);
  }
});

export default app;
