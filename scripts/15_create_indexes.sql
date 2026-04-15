-- ====================================================================
-- 4. Índice parcial: optimiza búsquedas de cuotas con saldo > 0
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_payment_schedule_saldo_pendiente
ON core.payment_schedule (saldo_pendiente)
WHERE saldo_pendiente > 0;



-- ============================================================
--   Validación rápida
-- ============================================================
-- Revisar los primeros 10 schedules con estado y saldo actualizado
SELECT schedule_id, num_cuota, valor_cuota, saldo_pendiente, estado
FROM core.payment_schedule
ORDER BY schedule_id
LIMIT 10;
