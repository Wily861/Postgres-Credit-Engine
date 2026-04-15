-- ============================================================
-- 1. Agregar columna persistida: saldo_pendiente
-- ============================================================
ALTER TABLE core.payment_schedule
ADD COLUMN IF NOT EXISTS saldo_pendiente NUMERIC(12,2) DEFAULT 0;
