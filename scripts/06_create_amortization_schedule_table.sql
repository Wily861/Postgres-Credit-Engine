-- 6. Crear tabla de pagos
CREATE TABLE IF NOT EXISTS core.pagos (
  pago_id BIGSERIAL PRIMARY KEY,
  schedule_id BIGINT NOT NULL REFERENCES core.payment_schedule(schedule_id),
  fecha_pago TIMESTAMPTZ NOT NULL,
  monto NUMERIC(12,2) NOT NULL,
  medio TEXT
);
