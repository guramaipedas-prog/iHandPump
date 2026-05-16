import { Hono } from 'hono';

const app = new Hono();

// GET /api/uang-jalan/templates
app.get('/templates', async (c) => {
  try {
    const templates = await c.env.db.getAllUangJalanTemplates();
    return c.json({ success: true, count: templates.length, data: templates });
  } catch (error) {
    console.error('Error fetching templates:', error);
    return c.json({ success: false, error: 'Gagal mengambil template uang jalan' }, 500);
  }
});

// POST /api/uang-jalan/calculate
app.post('/calculate', async (c) => {
  try {
    const body = await c.req.json();
    const { jarak_km, konsumsi_bbm, harga_bbm, biaya_tol, biaya_makan } = body;

    if (!jarak_km) {
      return c.json({ success: false, error: 'Jarak KM wajib diisi' }, 400);
    }

    const result = await c.env.db.calculateUangJalan({
      jarak_km: parseFloat(jarak_km),
      konsumsi_bbm: konsumsi_bbm ? parseFloat(konsumsi_bbm) : 5,
      harga_bbm: harga_bbm ? parseFloat(harga_bbm) : 10000,
      biaya_tol: biaya_tol ? parseFloat(biaya_tol) : 0,
      biaya_makan: biaya_makan ? parseFloat(biaya_makan) : 0
    });

    return c.json({ success: true, data: result });
  } catch (error) {
    console.error('Error calculating uang jalan:', error);
    return c.json({ success: false, error: 'Gagal menghitung uang jalan' }, 500);
  }
});

// GET /api/uang-jalan/fuel-prices
app.get('/fuel-prices', async (c) => {
  try {
    const prices = await c.env.db.getAllFuelPrices();
    return c.json({ success: true, data: prices });
  } catch (error) {
    console.error('Error fetching fuel prices:', error);
    return c.json({ success: false, error: 'Gagal mengambil harga BBM' }, 500);
  }
});

export default app;
