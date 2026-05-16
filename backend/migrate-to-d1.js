const { Pool } = require('pg');
const fs = require('fs');

// Railway PostgreSQL connection
const RAILWAY_DB_URL = 'postgresql://postgres:CWGrNGxKKyDeIHzDpjrmWspxBKWwFtzC@ballast.proxy.rlwy.net:55131/railway';

// D1 migration output file
const OUTPUT_FILE = './cf-workers/migrations/0002_import_railway_data.sql';

async function connectWithRetry(maxRetries = 5, delay = 5000) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const pool = new Pool({
        connectionString: RAILWAY_DB_URL,
        ssl: { rejectUnauthorized: false },
        connectionTimeoutMillis: 15000,
        query_timeout: 60000
      });
      
      // Test connection
      const client = await pool.connect();
      await client.query('SELECT 1');
      client.release();
      
      console.log(`✅ Connected on attempt ${i + 1}`);
      return pool;
    } catch (err) {
      console.log(`⚠️ Attempt ${i + 1}/${maxRetries} failed: ${err.message}`);
      if (i < maxRetries - 1) {
        console.log(`⏳ Waiting ${delay / 1000}s before retry...`);
        await new Promise(r => setTimeout(r, delay));
      } else {
        throw err;
      }
    }
  }
}

async function getTables(pool) {
  const result = await pool.query(`
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
    AND table_name NOT IN ('pg_stat_statements')
    ORDER BY table_name
  `);
  return result.rows.map(r => r.table_name);
}

async function getTableData(pool, tableName) {
  const result = await pool.query(`SELECT * FROM "${tableName}"`);
  return result.rows;
}

function escapeValue(val) {
  if (val === null || val === undefined) return 'NULL';
  if (typeof val === 'boolean') return val ? 1 : 0;
  if (typeof val === 'number') return val;
  if (val instanceof Date) return `'${val.toISOString()}'`;
  if (typeof val === 'object') return `'${JSON.stringify(val).replace(/'/g, "''")}'`;
  return `'${String(val).replace(/'/g, "''")}'`;
}

function generateInsertSQL(tableName, rows) {
  if (rows.length === 0) return '';
  
  const columns = Object.keys(rows[0]);
  const colStr = columns.map(c => `"${c}"`).join(', ');
  
  // D1 has query size limits, batch into chunks of 50
  const chunkSize = 50;
  let sql = '';
  
  for (let i = 0; i < rows.length; i += chunkSize) {
    const chunk = rows.slice(i, i + chunkSize);
    const values = chunk.map(row => {
      return '(' + columns.map(col => escapeValue(row[col])).join(', ') + ')';
    }).join(',\n');
    
    sql += `INSERT INTO "${tableName}" (${colStr}) VALUES\n${values};\n`;
  }
  
  return sql;
}

async function migrate() {
  console.log('🔌 Connecting to Railway PostgreSQL...');
  
  let pool;
  try {
    pool = await connectWithRetry();
  } catch (err) {
    console.error('❌ Failed to connect after retries:', err.message);
    console.log('\n💡 Railway database may be sleeping. Trying local SQLite as fallback...');
    return;
  }
  
  try {
    const tables = await getTables(pool);
    console.log(`📊 Found tables: ${tables.join(', ')}`);
    
    let sqlOutput = '';
    sqlOutput += '-- ============================================================\n';
    sqlOutput += '-- Migration: Import data from Railway PostgreSQL to D1\n';
    sqlOutput += '-- Generated: ' + new Date().toISOString() + '\n';
    sqlOutput += '-- ============================================================\n\n';
    sqlOutput += 'PRAGMA foreign_keys = OFF;\n\n';
    
    for (const table of tables) {
      console.log(`\n📥 Exporting ${table}...`);
      const rows = await getTableData(pool, table);
      console.log(`   Found ${rows.length} rows`);
      
      if (rows.length > 0) {
        sqlOutput += `-- Table: ${table} (${rows.length} rows)\n`;
        sqlOutput += `DELETE FROM "${table}";\n`;
        sqlOutput += generateInsertSQL(table, rows);
        sqlOutput += '\n';
      }
    }
    
    sqlOutput += 'PRAGMA foreign_keys = ON;\n';
    
    const outputPath = '../' + OUTPUT_FILE;
    fs.writeFileSync(outputPath, sqlOutput);
    console.log(`\n✅ Migration SQL saved to: ${outputPath}`);
    console.log(`📦 Total size: ${(fs.statSync(outputPath).size / 1024).toFixed(2)} KB`);
    
  } catch (err) {
    console.error('❌ Error:', err.message);
  } finally {
    await pool.end();
  }
}

migrate();
