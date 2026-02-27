# 🏦 Sistema de Gestión de Créditos: Arquitectura en PostgreSQL

> **Caso Técnico de Ingeniería de Datos:** Modelado, automatización y optimización de un ecosistema financiero robusto utilizando PostgreSQL.

---

## 🎯 Objetivo del Proyecto
Desarrollar una infraestructura de base de datos que garantice la **integridad referencial** y la **consistencia ACID** para un sistema de créditos, implementando lógica de negocio directamente en el motor mediante **PL/pgSQL**.

---

## 🛠️ Stack Tecnológico
* **Engine:** PostgreSQL 15+
* **Environment:** pgAdmin 4 / PSQL
* **Language:** SQL / PLpgSQL (Stored Procedures & Triggers)
* **Modeling:** Entidad-Relación (Relational Modeling)

---

## 📂 Arquitectura y Contenido Técnico

### 1. Modelado de Datos (Esquema Relacional)
Diseño de tablas normalizadas para asegurar la escalabilidad:
* **Core:** Clientes, Créditos y Cronogramas de Pago.
* **Transaccional:** Gestión de Pagos e histórico de movimientos.

### 2. Automatización & Business Logic
Implementación de **Triggers y Funciones (PL/pgSQL)** para:
* Cálculo automático de saldos e intereses.
* Validación de estados de crédito en tiempo real.
* Generación dinámica de cronogramas de pago.

### 3. Optimización de Performance
* **Indexación Estratégica:** Implementación de índices B-Tree para acelerar consultas financieras de alto volumen.
* **Integridad:** Constraints avanzadas (`CHECK`, `FOREIGN KEY`, `NOT NULL`) para evitar la corrupción de datos financieros.

### 4. Análisis de Datos
Scripts de consulta avanzados para:
* Reporteo de cartera vencida.
* Análisis de comportamiento de pagos por cliente.
* Validación de consistencia financiera.
--- 

## Creación base de datos

```SQL 
-- Creación base de datos
CREATE DATABASE roda_test;

```
![Creación base de datos](https://drive.google.com/uc?export=view&id=1KBSyXTP2EsMn778GXNMF_2PfiQb2e18S)

--- 

## Creación de esquemas 

```SQL
-- Creación de esquema "core"
CREATE SCHEMA IF NOT EXISTS core;

```

![Creación de esquema](https://drive.google.com/uc?export=view&id=1EFREK_Gil_LOfpioajG2ks7eNNi1vQsv)

--- 

## Creación de tablas

-	Tabla clientes

```SQL
-- 2. Crear tabla de clientes
CREATE TABLE IF NOT EXISTS core.clientes (
  cliente_id BIGSERIAL PRIMARY KEY,
  tipo_doc   TEXT NOT NULL,
  num_doc    TEXT NOT NULL,
  nombre     TEXT NOT NULL,
  ciudad     TEXT,
  UNIQUE (tipo_doc, num_doc)
);

```
![Tabla Cliente](https://drive.google.com/uc?export=view&id=1K1yVYyNgrC-MouYfBxSD6DwfmCU5xYri)

--- 
## Tabla créditos 

```SQL
-- 3. Crear tabla de créditos
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

```
![Tabla Créditos](https://drive.google.com/uc?export=view&id=1suyd9RbnOg_JxkthEgnc2vCepaL-gs-q)

---

## Tabla payment_schedule 

```SQL
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

```
![Tabla payment_schedule](https://drive.google.com/uc?export=view&id=1h5HVm9QRJ7agvAVs6SpZ__zwqJjplTm7)

--- 
## Tabla de pagos

```SQL
-- 5. Crear tabla de pagos
CREATE TABLE IF NOT EXISTS core.pagos (
  pago_id BIGSERIAL PRIMARY KEY,
  schedule_id BIGINT NOT NULL REFERENCES core.payment_schedule(schedule_id),
  fecha_pago TIMESTAMPTZ NOT NULL,
  monto NUMERIC(12,2) NOT NULL,
  medio TEXT
);

```
![Tabla de Pagos](https://drive.google.com/uc?export=view&id=1KRQyPSCIYB4U-rSwVHvSDxpcgSLbHnZI)

---
## Inserción de registros a tablas 

```SQL
-- 30 registros insertados en la tabla clientes

-- Insertar 30 clientes de ejemplo en core.clientes
INSERT INTO core.clientes (tipo_doc, num_doc, nombre, ciudad) VALUES
('DNI','10000001','Juan Pérez','Lima'),
('DNI','10000002','María Gómez','Bogotá'),
('CE','10000003','Carlos Ruiz','Quito'),
('DNI','10000004','Ana Torres','Medellín'),
('DNI','10000005','Luis Fernández','Arequipa'),
('CE','10000006','Patricia López','Santiago'),
('DNI','10000007','Miguel Castro','Ciudad de México'),
('DNI','10000008','Rosa Martínez','Lima'),
('DNI','10000009','Jorge Ramírez','Bogotá'),
('CE','10000010','Lucía Vargas','Quito'),
('DNI','10000011','Pedro Sánchez','Medellín'),
('DNI','10000012','Camila Herrera','Arequipa'),
('CE','10000013','Andrés González','Santiago'),
('DNI','10000014','Sofía Rojas','Ciudad de México'),
('DNI','10000015','Ricardo Mendoza','Lima'),
('DNI','10000016','Valeria Morales','Bogotá'),
('CE','10000017','Daniela Paredes','Quito'),
('DNI','10000018','Hugo Delgado','Medellín'),
('DNI','10000019','Gabriela Ramos','Arequipa'),
('CE','10000020','Sebastián Cruz','Santiago'),
('DNI','10000021','Natalia Silva','Ciudad de México'),
('DNI','10000022','Diego Navarro','Lima'),
('CE','10000023','Carolina Vega','Bogotá'),
('DNI','10000024','Francisco Castillo','Quito'),
('DNI','10000025','Elena Morales','Medellín'),
('DNI','10000026','Rodrigo Ponce','Arequipa'),
('CE','10000027','Marisol Cárdenas','Santiago'),
('DNI','10000028','Felipe Ortega','Ciudad de México'),
('DNI','10000029','Alejandra Díaz','Lima'),
('DNI','10000030','Manuel Peña','Bogotá');

```
![Inserción de Registros](https://drive.google.com/uc?export=view&id=1r4z3yo-V_vYeZBkcjLq5Cg0uEEEsp7LS)

## Resultado
- Validación del total de registros insertados
![Cantidad de Registros](https://drive.google.com/uc?export=view&id=1yBnZ-HKblkgIoqcNxMxV02EYJea_6xRo)

- Ver los primeros 10 registros
![10 registros](https://drive.google.com/uc?export=view&id=12ylEje1SckvGPDYe3Hf4SvuP-6trls6M)

--- 

## Inserción de créditos por cliente 

```SQL
----------------------------------------------------------------------
-- 1. Insertar ~60 créditos (2 por cliente)
-- Cada cliente obtiene 2 créditos: uno e-bike y otro e-moped
----------------------------------------------------------------------
INSERT INTO core.creditos (cliente_id, producto, inversion, cuotas_totales, tea, fecha_desembolso, fecha_inicio_pago)
SELECT 
  c.cliente_id,
  (ARRAY['e-bike','e-moped'])[ (random()*1+1)::int ], -- elige aleatorio entre e-bike / e-moped
  (500 + random()*2500)::numeric(12,2),              -- monto entre 500 y 3000
  (6 + (random()*6)::int),                           -- cuotas entre 6 y 12
  0.25,                                              -- TEA fija de 25% (ejemplo)
  CURRENT_DATE - (random()*100)::int,                -- fecha desembolso hasta 100 días atrás
  CURRENT_DATE + (random()*5)::int                   -- inicio de pago en próximos 5 días
FROM core.clientes c
CROSS JOIN generate_series(1,2) g; -- 2 créditos por cliente
----------------------------------------------------------------------
-- Resultado: 30 clientes x 2 créditos = 60 créditos
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 2. Insertar cuotas de cada crédito en payment_schedule
-- Se generan de acuerdo al número de cuotas de cada crédito
----------------------------------------------------------------------
INSERT INTO core.payment_schedule (credito_id, num_cuota, fecha_vencimiento, valor_cuota)
SELECT 
  cr.credito_id,
  gs AS num_cuota,
  cr.fecha_inicio_pago + (gs * interval '1 month') AS fecha_vencimiento,
  ROUND(cr.inversion / cr.cuotas_totales, 2) AS valor_cuota
FROM core.creditos cr
JOIN generate_series(1,12) gs ON gs <= cr.cuotas_totales;
----------------------------------------------------------------------
-- Resultado: cada crédito tendrá entre 6 y 12 cuotas
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 3. Insertar pagos (completos, parciales, atrasados, 1 prepago)
----------------------------------------------------------------------

-- 3.a Pagos normales (70% completos, 30% parciales)
INSERT INTO core.pagos (schedule_id, fecha_pago, monto, medio)
SELECT 
  ps.schedule_id,
  ps.fecha_vencimiento - (random()*10)::int, -- pago hasta 10 días antes
  CASE 
    WHEN random() < 0.7 THEN ps.valor_cuota              -- pago completo
    ELSE ps.valor_cuota * (0.5 + random()*0.4)           -- pago parcial (50–90%)
  END,
  (ARRAY['efectivo','billetera_digital','transferencia'])[ (random()*2+1)::int ]
FROM core.payment_schedule ps
WHERE ps.num_cuota <= 3; -- solo primeras 3 cuotas (las demás quedan pendientes)


-- 3.b Pagos atrasados (después de la fecha de vencimiento)
INSERT INTO core.pagos (schedule_id, fecha_pago, monto, medio)
SELECT 
  ps.schedule_id,
  ps.fecha_vencimiento + (1 + random()*5)::int, -- pago 1–5 días después
  ps.valor_cuota,
  'efectivo'
FROM core.payment_schedule ps
WHERE ps.num_cuota = 2
LIMIT 5;

-- 3.c Pago prepago (antes de la fecha de vencimiento de la primera cuota)
INSERT INTO core.pagos (schedule_id, fecha_pago, monto, medio)
SELECT 
  ps.schedule_id,
  ps.fecha_vencimiento - interval '20 days',
  ps.valor_cuota,
  'transferencia'
FROM core.payment_schedule ps
WHERE ps.num_cuota = 1
LIMIT 1;

```

![Crédito por Cliente](https://drive.google.com/uc?export=view&id=1t6YOObTQlGPnf3h6HxJ_nATP0JzrNPIn)

--- 

## Resultados 

- Cantidad de créditos insertados 

```SQL
-- 1 Contar créditos insertados
SELECT COUNT(*) FROM core.creditos; 

```
![Créditos insertados](https://drive.google.com/uc?export=view&id=1kmVlh5hy2wy01wYTsUyNeL2jN9mH2ZCp)

- Cantidad de cuotas

```SQL
-- 2 Contar cuotas
SELECT COUNT(*) FROM core.payment_schedule;
```
![Cantidad de Cuotas](https://drive.google.com/uc?export=view&id=1d9KPDEW_qc0JPVGUcad3Ag84wCwTvOYY)

- Cantidad de pagos
  
```SQL
-- 3 Contar pagos
SELECT COUNT(*) FROM core.pagos;
```
![Contar Pagos](https://drive.google.com/uc?export=view&id=1lM6tTRYORoeOr-6WOkXEBHmcPwbY0VcH)

- Pagos completos, parciales, atrasados y pre-pagos (máx. 10 registros)

```SQL
/* ============================================================
   Validación de pagos (máx. 10 registros variados)
   Objetivo:
     - Mostrar una muestra de hasta 10 registros
     - Clasificar pagos en 4 tipos clave:
         ✔ Completo : monto = valor_cuota y pago puntual
         ✔ Parcial  : monto < valor_cuota y pago puntual
         ✔ Atrasado : fecha_pago > fecha_vencimiento
         ✔ Prepago  : fecha_pago < fecha_vencimiento
   Notas:
     - Se asegura que al menos un registro de cada tipo aparezca
       (si existen en los datos).
     - Útil para auditar la semilla de datos.
   ============================================================ */

WITH pagos_clasificados AS (
    SELECT 
        c.nombre              AS cliente,           
        cr.producto           AS producto,          
        ps.num_cuota          AS cuota,             
        ps.fecha_vencimiento  AS fecha_vencimiento, 
        ps.valor_cuota        AS valor_cuota,       
        p.pago_id             AS pago_id,           
        p.fecha_pago          AS fecha_pago,        
        p.monto               AS monto_pagado,      
        p.medio               AS medio_pago,        

        -- Clasificación del pago según reglas
        CASE
            WHEN p.monto = ps.valor_cuota 
                 AND p.fecha_pago <= ps.fecha_vencimiento 
              THEN 'Completo'
            WHEN p.monto < ps.valor_cuota 
                 AND p.fecha_pago <= ps.fecha_vencimiento 
              THEN 'Parcial'
            WHEN p.fecha_pago > ps.fecha_vencimiento 
              THEN 'Atrasado'
            WHEN p.fecha_pago < ps.fecha_vencimiento 
              THEN 'Prepago'
            ELSE 'Otro'
        END AS tipo_pago
    FROM core.pagos p
    JOIN core.payment_schedule ps 
      ON p.schedule_id = ps.schedule_id
    JOIN core.creditos cr 
      ON ps.credito_id = cr.credito_id
    JOIN core.clientes c 
      ON cr.cliente_id = c.cliente_id
),

-- Trae al menos 1 por cada tipo (si existe)
muestra_por_tipo AS (
    SELECT DISTINCT ON (tipo_pago) *
    FROM pagos_clasificados
    WHERE tipo_pago IN ('Completo','Parcial','Atrasado','Prepago')
    ORDER BY tipo_pago, RANDOM()
),

-- Rellenar con otros hasta llegar a 10
muestra_complemento AS (
    SELECT pc.*
    FROM pagos_clasificados pc
    WHERE pc.pago_id NOT IN (SELECT pago_id FROM muestra_por_tipo)
    ORDER BY RANDOM()
    LIMIT (10 - (SELECT COUNT(*) FROM muestra_por_tipo))
)

-- Unión final
SELECT *
FROM (
    SELECT * FROM muestra_por_tipo
    UNION ALL
    SELECT * FROM muestra_complemento
) final
ORDER BY tipo_pago, cliente;
```
![Validación de Pagos](https://drive.google.com/uc?export=view&id=1Q0Vkmo6p6OqwKpPZ3p2mK4hvTUvQ6O3s)

--- 

## Tareas (lo mínimo valioso)

-  1. Análisis (consultas)

```SQL
/* ------------------------------------------------------------
   1.a Clientes con créditos vigentes (financiamiento oportuno)
   ------------------------------------------------------------ */
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.cliente_id, c.nombre, cr.credito_id, cr.producto, cr.inversion,
       cr.cuotas_totales, cr.fecha_desembolso, cr.fecha_inicio_pago, cr.tea,
       (SELECT COALESCE(SUM(valor_cuota),0) 
        FROM core.payment_schedule ps 
        WHERE ps.credito_id=cr.credito_id) AS total_programado,
       (SELECT COALESCE(SUM(p.monto),0) 
        FROM core.pagos p 
        JOIN core.payment_schedule ps ON p.schedule_id=ps.schedule_id 
        WHERE ps.credito_id=cr.credito_id) AS total_pagado
FROM core.clientes c
JOIN core.creditos cr ON cr.cliente_id=c.cliente_id
WHERE cr.estado='vigente';
/* ------------------------------------------------------------
   1.b Créditos con cuotas vencidas sin pagar
   ------------------------------------------------------------ */
EXPLAIN (ANALYZE, BUFFERS)
SELECT cr.credito_id, c.nombre, COUNT(*) AS cuotas_vencidas
FROM core.creditos cr
JOIN core.payment_schedule ps ON ps.credito_id=cr.credito_id
LEFT JOIN (
  SELECT schedule_id, SUM(monto) AS pagado 
  FROM core.pagos 
  GROUP BY schedule_id
) agg ON agg.schedule_id=ps.schedule_id
JOIN core.clientes c ON c.cliente_id=cr.cliente_id
WHERE ps.fecha_vencimiento < CURRENT_DATE
  AND COALESCE(agg.pagado,0) < ps.valor_cuota
GROUP BY cr.credito_id, c.nombre
ORDER BY cuotas_vencidas DESC;

/* ------------------------------------------------------------
   1.c Pagos por cuota del payment_schedule
   ------------------------------------------------------------ */
EXPLAIN (ANALYZE, BUFFERS)
SELECT ps.credito_id, ps.num_cuota, ps.fecha_vencimiento,
       p.pago_id, p.fecha_pago, p.monto, p.medio
FROM core.payment_schedule ps
LEFT JOIN core.pagos p ON p.schedule_id=ps.schedule_id
ORDER BY ps.credito_id, ps.num_cuota, p.fecha_pago;
```
![Crédito Vigente](https://drive.google.com/uc?export=view&id=1htR2UfOEqc_6e3wg3zcnaYhYUKTb6U0N)

---

## triggers_indexes

- Script y resultado

```SQL
-- ============================================================
-- 1. Agregar columna persistida: saldo_pendiente
-- ============================================================
ALTER TABLE core.payment_schedule
ADD COLUMN IF NOT EXISTS saldo_pendiente NUMERIC(12,2) DEFAULT 0;

```
![Agregar Columna](https://drive.google.com/uc?export=view&id=1K3aGogt0Fi4TxPmf4Sbo-OAV0mCXKFTf)

--- 

## Inicializar valores existentes 

```SQL
-- Inicializar valores existentes (saldo = valor cuota)
UPDATE core.payment_schedule
SET saldo_pendiente = valor_cuota
WHERE saldo_pendiente = 0;

```
![Inicializar Valores](https://drive.google.com/uc?export=view&id=11dXd9g299wBkx8vqsOwnN5e8Mw-TPrmH)

- Después de la inicialización
   
```SQL
-- 1. Revisar que no existan cuotas con saldo_pendiente = 0
SELECT COUNT(*) AS cuotas_saldo_cero
FROM core.payment_schedule
WHERE saldo_pendiente = 0;
```
![Después de Inicialización](https://drive.google.com/uc?export=view&id=12PKUqIdlkhKgK8QCiKdYg4cnCxdIcIsq)

```SQL
-- 2. Revisar consistencia: saldo_pendiente debe ser igual a valor_cuota
--    (solo antes de registrar pagos reales)
SELECT COUNT(*) AS inconsistencias
FROM core.payment_schedule
WHERE saldo_pendiente <> valor_cuota;
```
![Constancia](https://drive.google.com/uc?export=view&id=11fCIRqkYMpqka_iGzDBErQOZtA7vWJIk)

```SQL
-- 3. Mostrar una muestra de 10 registros para inspección manual
SELECT schedule_id, credito_id, num_cuota, valor_cuota, saldo_pendiente
FROM core.payment_schedule
ORDER BY schedule_id
LIMIT 10;
```
![Muestra](https://drive.google.com/uc?export=view&id=1q3XiLB5fDGPRQmXuQGUtTM6XrblRSTrD)

--- 
## Creación unción y trigger

```SQL 
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
```
![Función y Trigger](https://drive.google.com/uc?export=view&id=1WpmYrN2sSHLC76zXlDpGdRZPvx5_PItT)

--- 
## Función y Trigger para actualizar saldo y estado de la cuota

```SQL 
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
```
```SQL
-- ============================================================
-- 4. Prueba de inserción y verificación de resultado
-- ============================================================

-- Simular un pago
INSERT INTO core.pagos (schedule_id, monto, fecha_pago)
VALUES (1, 100000, CURRENT_DATE);

-- Verificar el resultado actualizado
SELECT schedule_id, valor_cuota, saldo_pendiente, estado, fecha_vencimiento
FROM core.payment_schedule
WHERE schedule_id = 1;
```
![Verificar Resultado](https://drive.google.com/uc?export=view&id=1nbJxx6Sv7IRJnJmUy05bw6fTrB8fRoGi)

--- 
## Índice

```SQL
-- ============================================================
-- 4. Índice parcial: optimiza búsquedas de cuotas con saldo > 0
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_payment_schedule_saldo_pendiente
ON core.payment_schedule (saldo_pendiente)
WHERE saldo_pendiente > 0;
```
![Índice Parcial](https://drive.google.com/uc?export=view&id=1JemXVkNq1zkiPt2qikdn8sTJ2JmfW6CE)

```SQL
/* ============================================================
   Validación rápida
   ============================================================ */
-- Revisar los primeros 10 schedules con estado y saldo actualizado
SELECT schedule_id, num_cuota, valor_cuota, saldo_pendiente, estado
FROM core.payment_schedule
ORDER BY schedule_id
LIMIT 10;
```

![Validar Índice](https://drive.google.com/uc?export=view&id=1yjXcZzNc7qs2X8a6shNUIeQrkyrYAquR)

--- 

## Índices recomendados ejecutados 

```SQL
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
```
![Índice Recomendado](https://drive.google.com/uc?export=view&id=1ZTBx6U3IZHlWcViquyNubHMSMYn0-N5g)

--- 
```SQL
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
```
![Buffer](https://drive.google.com/uc?export=view&id=1J8QxtFdQNX2143iaCBwEIj1GQpSx8tE2)

```SQL
-- 2 Consulta optimizada (después de aplicar 1.b)
EXPLAIN (ANALYZE, BUFFERS)
SELECT fecha_vencimiento, credito_id, num_cuota, saldo_pendiente
FROM core.payment_schedule
WHERE estado IN ('pendiente','parcial')
  AND fecha_vencimiento < CURRENT_DATE;
```
![Consulta Optimizada](https://drive.google.com/uc?export=view&id=1HMgGk80s50Lsgr_hUaoVwnGXCeHB4orf)

--- 

## 5) Plan de Transición de Desarrollo a Producción

Para asegurar un despliegue **dev → prod** sin fricción, se propone un plan basado en las mejores prácticas de la industria, garantizando la integridad de los datos y la continuidad del servicio.

### 1. Gestión de Entornos y Esquemas Separados
- Se recomienda usar **esquemas de bases de datos separados** (dev y prod) dentro de una misma instancia, o bien **entornos totalmente distintos** para cada etapa del desarrollo.  
- Esto permite:
  - Probar con datos de desarrollo sin afectar la base de datos de producción.
  - Mantener la estructura del código y los scripts de migración consistentes.

### 2. Pipeline de Migraciones Simple
- El despliegue se gestiona mediante **scripts de migración con control de versiones** (ej. `V1__create_schema_dev.sql`, `V2__create_tables.sql`).  
- Flujo recomendado:
  1. Aplicar los scripts primero en **dev** para probar lógica y rendimiento.
  2. Una vez validados, aplicarlos en **producción** usando:
     - **Transacciones** para asegurar atomicidad.
     - **CONCURRENTLY** al crear índices, minimizando bloqueos y evitando interrupciones al servicio.

### 3. Plan de Rollback y Auditoría
- Antes de cualquier despliegue en producción:
  - Realizar **copia de seguridad** de la base de datos (ej. `pg_dump`) como red de seguridad.
  - Implementar **tabla de auditoría** con triggers (ej. `audit_log`) para registrar modificaciones en tablas críticas.  
- Beneficios:
  - Trazabilidad completa de cambios.
  - Recuperación rápida en caso de incidentes.



