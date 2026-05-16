# 🚀 Migrasi Railway → Cloudflare Workers + D1

Panduan lengkap migrasi project iHandPump dari Railway ke Cloudflare.

## 📁 Struktur Baru

```
.
├── cf-workers/          # Backend API (Cloudflare Workers)
│   ├── src/
│   │   ├── index.js     # Entry point Hono
│   │   ├── db.js        # D1 Database Adapter
│   │   └── routes/      # API Routes
│   ├── migrations/      # D1 SQL Migrations
│   ├── wrangler.toml    # Konfigurasi Workers
│   └── package.json
│
├── cf-pages/            # Frontend Static (Cloudflare Pages)
│   ├── admin/           # Admin Dashboard
│   └── tracking/        # Tracking Public
│
└── backend/             # Code lama Railway (backup)
```

## ⚡ Langkah Deploy

### 1. Login Cloudflare (lakukan di terminal)

```bash
cd cf-workers
npx wrangler login
```

Buka browser dan authorize Wrangler CLI.

### 2. Buat D1 Database

```bash
npx wrangler d1 create ihandpump-db
```

**Catat `database_id` yang muncul**, lalu edit `wrangler.toml`:

```toml
[[d1_databases]]
binding = "DB"
database_name = "ihandpump-db"
database_id = "xxxxx-database-id-anda-xxxxx"
```

### 3. Jalankan Migration

```bash
npx wrangler d1 migrations apply ihandpump-db
```

### 4. Deploy Workers (Backend API)

```bash
npm run deploy
```

**Catat URL Workers** (misal: `https://ihandpump-api.your-subdomain.workers.dev`)

### 5. Deploy Pages (Frontend Static)

#### Admin Website:
```bash
cd ../cf-pages/admin
npx wrangler pages deploy . --project-name=ihandpump-admin
```

#### Tracking Website:
```bash
cd ../tracking
npx wrangler pages deploy . --project-name=ihandpump-tracking
```

### 6. Update API URL di Frontend

Setelah deploy, update URL API di file frontend:

**`cf-pages/admin/index.html`** (sekitar baris 1038):
```javascript
const API_URL = 'https://ihandpump-api.your-subdomain.workers.dev/api';
```

**`cf-pages/tracking/index.html`** (sekitar baris 792):
```javascript
BASE_URL: 'https://ihandpump-api.your-subdomain.workers.dev'
```

Lalu re-deploy Pages:
```bash
npx wrangler pages deploy . --project-name=ihandpump-admin
npx wrangler pages deploy . --project-name=ihandpump-tracking
```

## 🔧 Environment Variables & Secrets

Jika butuh API Key atau secrets:

```bash
npx wrangler secret put API_KEY
```

## ✅ Perbandingan: Railway vs Cloudflare

| Fitur | Railway | Cloudflare Workers |
|-------|---------|-------------------|
| Backend | Express.js | Hono (Edge) |
| Database | PostgreSQL/SQLite | D1 (SQLite Edge) |
| Static Hosting | Railway | Pages |
| Biaya | $5+/bulan | **Free tier tersedia** |
| Cold Start | Ya | **Zero cold start** |
| Global CDN | Tidak | **300+ lokasi** |

## 🧪 Test Lokal

```bash
cd cf-workers
npm run dev
```

Buka `http://localhost:8787/api/health`

## 📝 API Endpoints

Semua endpoint sama dengan Railway:
- `GET /api/health` - Health check
- `GET /api/orders` - List orders
- `POST /api/orders` - Create order
- `GET /api/drivers` - List drivers
- `GET /api/customers` - List customers
- `GET /api/billing` - List tagihan
- `GET /api/dashboard/stats` - Dashboard stats
- ...dan lainnya

## 🔗 GitHub Integration

Untuk auto-deploy dari GitHub:
1. Push repo ke `guramaipedas-prog/iHandPump`
2. Di Cloudflare Dashboard → Workers & Pages → Connect to Git
3. Pilih repo dan branch
4. Setup build command sesuai project
