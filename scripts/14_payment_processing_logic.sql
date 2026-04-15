-- ============================================================
-- 3. Función y Trigger para actualizar saldo y estado de la cuota
-- ============================================================
-- Estados esperados:
--   - pagada   : cuando saldo_pendiente <= 0
--   - parcial  : cuando saldo_pendiente < valor_cuota y > 0
--   - vencida  : cuando fecha_vencimiento < CURRENT_DATE y saldo > 0
--   - pendiente: cuando aún no se paga nada y no está vencida
-- ============================================================

-- Agregar columna de estado si no existe
ALTER TABLE core.payment_schedule
ADD COLUMN IF NOT EXISTS estado VARCHAR(20) DEFAULT 'pendiente';


-- Función que actualiza saldo_pendiente y estado de la cuota
CREATE OR REPLACE FUNCTION core.fn_actualizar_saldo_y_estado()
RETURNS TRIGGER AS $$
DECLARE
  v_total_pagado NUMERIC(12,2);
  v_valor NUMERIC(12,2);
  v_fecha DATE;
  v_saldo NUMERIC(12,2);
BEGIN

  -- Calcular total pagado para la cuota
  SELECT COALESCE(SUM(monto), 0)
  INTO v_total_pagado
  FROM core.pagos
  WHERE schedule_id = NEW.schedule_id;


  -- Obtener valor de la cuota y fecha de vencimiento
  SELECT valor_cuota, fecha_vencimiento
  INTO v_valor, v_fecha
  FROM core.payment_schedule
  WHERE schedule_id = NEW.schedule_id;

  -- Calcular saldo pendiente
  v_saldo := v_valor - v_total_pagado;

  -- Actualizar saldo y estado
  UPDATE core.payment_schedule
  SET saldo_pendiente = v_saldo,
      estado = CASE
        WHEN v_saldo <= 0 THEN 'pagada'
        WHEN v_saldo < v_valor AND v_saldo > 0 THEN 'parcial'
        WHEN v_fecha < CURRENT_DATE AND v_saldo > 0 THEN 'vencida'
        ELSE 'pendiente'
      END
  WHERE schedule_id = NEW.schedule_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;



-- Trigger que ejecuta la función después de insertar o actualizar pagos
CREATE OR REPLACE TRIGGER trg_actualizar_saldo_y_estado
AFTER INSERT OR UPDATE ON core.pagos
FOR EACH ROW
EXECUTE FUNCTION core.fn_actualizar_saldo_y_estado();
