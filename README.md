# 🏦 Sistema de Gestión de Créditos: Arquitectura en PostgreSQL

> **Caso Técnico de Ingeniería de Datos:** Modelado, automatización y optimización de un motor financiero robusto utilizando PostgreSQL.

---

## 🎯 Objetivo del Proyecto
Desarrollar una infraestructura de base de datos de alto rendimiento que garantice la **integridad referencial** y la **consistencia ACID**. El núcleo del proyecto reside en la implementación de lógica de negocio (cálculo de amortizaciones, estados de deuda y auditoría) directamente en el motor de base de datos mediante **PL/pgSQL**.

---

## 🛠️ Stack Tecnológico
* **Motor:** PostgreSQL 15+
* **Lenguaje Procedural:** PL/pgSQL (Triggers, Functions & Stored Procedures)
* **Modelado:** Entidad-Relación Relacional con aislamiento por esquemas.
* **Entorno:** pgAdmin 4 / PSQL Command Line.

---

## 📂 Estructura del Proyecto

Los recursos están organizados en un pipeline secuencial. **Haz clic en cada archivo para acceder al código fuente:**

* **[`scripts/01_create_database.sql`](./scripts/01_create_database.sql)** - Inicialización de la instancia.
* **[`scripts/02_create_schemas.sql`](./scripts/02_create_schemas.sql)** - Aislamiento de capas (Core, Security, Audit).
* **[`scripts/03_create_tables.sql`](./scripts/03_create_tables.sql)** - Definición de estructuras base.
* **[`scripts/04_create_loans_table.sql`](./scripts/04_create_loans_table.sql)** - Gestión de entidades de crédito.
* **[`scripts/05_create_payments_table.sql`](./scripts/05_create_payments_table.sql)** - Registro de transacciones monetarias.
* **[`scripts/06_create_amortization_schedule_table.sql`](./scripts/06_create_amortization_schedule_table.sql)** - Plan de pagos programado.
* **[`scripts/07_insert_initial_data.sql`](./scripts/07_insert_initial_data.sql)** - Datos maestros y catálogos.
* **[`scripts/08_insert_customer_loans.sql`](./scripts/08_insert_customer_loans.sql)** - Inserción de cartera activa.
* **[`scripts/09_queries_and_results.sql`](./scripts/09_queries_and_results.sql)** - Reportes y validación de lógica.
* **[`scripts/10_tasks.sql`](./scripts/10_tasks.sql)** - Tareas de mantenimiento MVP.
* **[`scripts/11_triggers_and_indexes.sql`](./scripts/11_triggers_and_indexes.sql)** - Optimizaciones y automatización inicial.
* **[`scripts/12_initialize_existing_values.sql`](./scripts/12_initialize_existing_values.sql)** - Sincronización de saldos históricos.
* **[`scripts/13_create_functions_and_triggers.sql`](./scripts/13_create_functions_and_triggers.sql)** - Funciones core de negocio y auditoría.
* **[`scripts/14_payment_processing_logic.sql`](./scripts/14_payment_processing_logic.sql)** - Motor de actualización automática de saldos.
* **[`scripts/15_create_indexes.sql`](./scripts/15_create_indexes.sql)** - Estrategia de indexación avanzada.
* **[`scripts/16_applied_performance_indexes.sql`](./scripts/16_applied_performance_indexes.sql)** - Índices de alto rendimiento para producción.
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
