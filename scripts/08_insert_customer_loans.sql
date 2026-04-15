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
