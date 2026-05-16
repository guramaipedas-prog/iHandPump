import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { DatabaseD1 } from './db.js';

// Import routes
import customers from './routes/customers.js';
import drivers from './routes/drivers.js';
import orders from './routes/orders.js';
import billing from './routes/billing.js';
import uangJalan from './routes/uang-jalan.js';
import tracking from './routes/tracking.js';

const app = new Hono();

// Middleware
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
  credentials: true
}));

app.use('*', logger());

// Database middleware
app.use('*', async (c, next) => {
  c.env.db = new DatabaseD1(c.env.DB);
  await next();
});

// Health check
app.get('/api/health', (c) => {
  return c.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: 'production',
    version: '2.0.0'
  });
});

// API Documentation
app.get('/api', (c) => {
  return c.json({
    name: 'Ekspedisi MVP API',
    version: '2.0.0',
    description: 'API untuk automasi internal usaha ekspedisi (Cloudflare Workers)',
    endpoints: {
      orders: {
        'GET /api/orders': 'List semua orders',
        'GET /api/orders/:id': 'Get single order',
        'POST /api/orders': 'Create order baru',
        'PUT /api/orders/:id': 'Update order',
        'PATCH /api/orders/:id/status': 'Update status order',
        'PATCH /api/orders/:id/assign-driver': 'Assign driver ke order',
        'PATCH /api/orders/:id/pod': 'Upload POD',
        'DELETE /api/orders/:id': 'Delete order'
      },
      customers: {
        'GET /api/customers': 'List customers',
        'POST /api/customers': 'Create customer',
        'PUT /api/customers/:id': 'Update customer',
        'DELETE /api/customers/:id': 'Delete customer'
      },
      drivers: {
        'GET /api/drivers': 'List drivers',
        'GET /api/drivers/available/list': 'List drivers tersedia',
        'POST /api/drivers': 'Create driver',
        'PUT /api/drivers/:id': 'Update driver',
        'DELETE /api/drivers/:id': 'Delete driver',
        'POST /api/drivers/logs': 'Create driver log (update dari sopir)'
      },
      billing: {
        'GET /api/billing': 'List tagihan',
        'GET /api/billing/ready/list': 'List order siap ditagih',
        'PATCH /api/billing/:id/status': 'Update status tagihan'
      },
      uang_jalan: {
        'GET /api/uang-jalan/templates': 'List template uang jalan',
        'POST /api/uang-jalan/calculate': 'Hitung uang jalan'
      },
      legacy: {
        'GET /api/track/:resi': 'Track shipment (legacy)',
        'GET /api/shipments': 'List shipments (legacy)'
      }
    }
  });
});

// Mount routes
app.route('/api/customers', customers);
app.route('/api/drivers', drivers);
app.route('/api/orders', orders);
app.route('/api/billing', billing);
app.route('/api/uang-jalan', uangJalan);
app.route('/api/shipments', tracking);
app.route('/api/track', tracking);

// Dashboard stats
app.get('/api/dashboard/stats', async (c) => {
  try {
    const { month, year } = c.req.query();
    const stats = await c.env.db.getDashboardStats({
      month: month ? parseInt(month) : null,
      year: year ? parseInt(year) : null
    });
    return c.json({ success: true, data: stats });
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    return c.json({ success: false, error: 'Gagal mengambil statistik dashboard' }, 500);
  }
});

app.get('/api/dashboard/periods', async (c) => {
  try {
    const periods = await c.env.db.getAvailablePeriods();
    return c.json({ success: true, data: periods });
  } catch (error) {
    console.error('Error fetching periods:', error);
    return c.json({ success: false, error: 'Gagal mengambil periode' }, 500);
  }
});

app.get('/api/dashboard/recent-orders', async (c) => {
  try {
    const { limit } = c.req.query();
    const orders = await c.env.db.getRecentOrders(limit ? parseInt(limit) : 10);
    return c.json({ success: true, data: orders });
  } catch (error) {
    console.error('Error fetching recent orders:', error);
    return c.json({ success: false, error: 'Gagal mengambil order terbaru' }, 500);
  }
});

// 404 handler
app.notFound((c) => {
  return c.json({ success: false, error: 'Endpoint tidak ditemukan' }, 404);
});

// Error handler
app.onError((err, c) => {
  console.error('Error:', err);
  return c.json({
    success: false,
    error: 'Terjadi kesalahan server'
  }, 500);
});

export default app;
