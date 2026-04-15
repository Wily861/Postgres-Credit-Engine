-- ============================================================
-- 2. Función y Trigger para actualizar saldo al registrar pago
-- ============================================================
CREATE OR REPLACE FUNCTION core.fn_actualizar_saldo()
RETURNS TRIGGER AS $$
BEGIN
  -- Descontar el pago del saldo pendiente
  UPDATE core.payment_schedule
  SET saldo_pendiente = saldo_pendiente - NEW.monto
  WHERE schedule_id = NEW.schedule_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_actualizar_saldo
AFTER INSERT ON core.pagos
FOR EACH ROW
EXECUTE FUNCTION core.fn_actualizar_saldo();
