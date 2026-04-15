-- 2. Crear tabla de clientes
CREATE TABLE IF NOT EXISTS core.clientes (
  cliente_id BIGSERIAL PRIMARY KEY,
  tipo_doc   TEXT NOT NULL,
  num_doc    TEXT NOT NULL,
  nombre     TEXT NOT NULL,
  ciudad     TEXT,
  UNIQUE (tipo_doc, num_doc)
);
