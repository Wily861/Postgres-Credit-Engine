-- Inicializar valores existentes (saldo = valor cuota)
UPDATE core.payment_schedule
SET saldo_pendiente = valor_cuota
WHERE saldo_pendiente = 0;

-- 1. Revisar que no existan cuotas con saldo_pendiente = 0
SELECT COUNT(*) AS cuotas_saldo_cero
FROM core.payment_schedule
WHERE saldo_pendiente = 0;

-- 2. Revisar consistencia: saldo_pendiente debe ser igual a valor_cuota
--    (solo antes de registrar pagos reales)
SELECT COUNT(*) AS inconsistencias
FROM core.payment_schedule
WHERE saldo_pendiente <> valor_cuota;

-- 3. Mostrar una muestra de 10 registros para inspección manual
SELECT schedule_id, credito_id, num_cuota, valor_cuota, saldo_pendiente
FROM core.payment_schedule
ORDER BY schedule_id
LIMIT 10;
