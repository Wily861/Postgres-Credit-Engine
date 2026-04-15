-- 4. Crear tabla de cronograma de pagos (cuotas)
CREATE TABLE IF NOT EXISTS core.payment_schedule (
  schedule_id BIGSERIAL PRIMARY KEY,
  credito_id  BIGINT NOT NULL REFERENCES core.creditos(credito_id),
  num_cuota   INT NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  valor_cuota NUMERIC(12,2) NOT NULL,
  estado      TEXT NOT NULL DEFAULT 'pendiente', -- pendiente|parcial|pagada|vencida
  UNIQUE (credito_id, num_cuota)
);
