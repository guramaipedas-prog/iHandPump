-- Add tanggal_muat column to orders table
ALTER TABLE orders ADD COLUMN tanggal_muat DATE;

-- Set default value for existing orders
UPDATE orders SET tanggal_muat = date(tanggal) WHERE tanggal_muat IS NULL;
