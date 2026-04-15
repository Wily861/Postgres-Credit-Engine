-- 1 Contar créditos insertados
SELECT COUNT(*) FROM core.creditos; 

-- 2 Contar cuotas
SELECT COUNT(*) FROM core.payment_schedule;

-- 3 Contar pagos
SELECT COUNT(*) FROM core.pagos;

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
