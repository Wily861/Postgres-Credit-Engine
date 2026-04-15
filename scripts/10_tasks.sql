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
