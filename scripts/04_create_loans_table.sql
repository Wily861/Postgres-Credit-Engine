-- 4. Crear tabla de créditos
CREATE TABLE IF NOT EXISTS core.creditos (
  credito_id BIGSERIAL PRIMARY KEY,
  cliente_id BIGINT NOT NULL REFERENCES core.clientes(cliente_id),
  producto   TEXT NOT NULL,            -- e-bike, e-moped
  inversion  NUMERIC(12,2) NOT NULL,
  cuotas_totales INT NOT NULL,
  tea        NUMERIC(8,6) NOT NULL,
  fecha_desembolso DATE NOT NULL,
  fecha_inicio_pago DATE NOT NULL,
  estado     TEXT NOT NULL DEFAULT 'vigente' -- vigente|cancelado|castigado
);
