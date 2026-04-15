-- ============================================================
-- 4. Índices recomendados para optimización mínima
-- ============================================================

-- Índice para cuotas vencidas en estado pendiente o parcial
CREATE INDEX IF NOT EXISTS ix_ps_vencidas
ON core.payment_schedule (fecha_vencimiento)
WHERE estado IN ('pendiente','parcial');

-- Índice compuesto por crédito y número de cuota
CREATE INDEX IF NOT EXISTS ix_ps_credito_cuota
ON core.payment_schedule (credito_id, num_cuota);

-- Índice para pagos por schedule y fecha
CREATE INDEX IF NOT EXISTS ix_pagos_schedule_fecha
ON core.pagos (schedule_id, fecha_pago);

-- Índice adicional si se persiste saldo
CREATE INDEX IF NOT EXISTS ix_ps_saldo_vencido
ON core.payment_schedule (fecha_vencimiento, saldo_pendiente)
WHERE saldo_pendiente > 0;


-- 1 Consulta original (antes de optimizar 1.b)
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM core.payment_schedule
WHERE estado IN ('pendiente','parcial')
  -- 1 Consulta original (antes de optimizar 1.b)
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM core.payment_schedule
WHERE estado IN ('pendiente','parcial')
  AND fecha_vencimiento < CURRENT_DATE;


-- 2 Consulta optimizada (después de aplicar 1.b)
EXPLAIN (ANALYZE, BUFFERS)
SELECT fecha_vencimiento, credito_id, num_cuota, saldo_pendiente
FROM core.payment_schedule
WHERE estado IN ('pendiente','parcial')
  AND fecha_vencimiento < CURRENT_DATE;
