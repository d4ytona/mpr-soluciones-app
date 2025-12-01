# Sistema de Logging de Cron Jobs - MPR Soluciones

## 🎯 Objetivo

Documentar y monitorear **cada ejecución** de los cron jobs en Supabase para tener visibilidad completa y permanente del sistema.

---

## 📊 ¿Qué se Registra?

### Cada vez que un cron ejecuta, se guarda en la base de datos:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `cron_name` | Nombre del cron | `generate-obligations` |
| `execution_time` | Cuándo se ejecutó | `2025-12-01 00:00:00` |
| `status` | Resultado | `success`, `error`, `partial` |
| `execution_duration_ms` | Cuánto tardó (ms) | `1250` (1.25 segundos) |
| `obligations_created` | Obligaciones creadas | `6` |
| `obligations_skipped` | Obligaciones existentes | `0` |
| `companies_processed` | Empresas procesadas | `3` |
| `notifications_created` | Notificaciones creadas | `12` |
| `obligations_checked` | Obligaciones revisadas | `45` |
| `details` | JSON completo de respuesta | `{...}` |
| `error_message` | Mensaje de error (si aplica) | `Connection timeout` |

---

## 🗄️ Tabla: `cron_execution_log`

### Estructura

```sql
CREATE TABLE public.cron_execution_log (
    id BIGSERIAL PRIMARY KEY,
    cron_name VARCHAR(100) NOT NULL,
    execution_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(20) NOT NULL CHECK (status IN ('success', 'error', 'partial')),

    -- Métricas para generate-obligations
    obligations_created INTEGER,
    obligations_skipped INTEGER,
    companies_processed INTEGER,

    -- Métricas para check-notifications
    notifications_created INTEGER,
    obligations_checked INTEGER,

    -- Detalles y errores
    details JSONB,
    error_message TEXT,
    execution_duration_ms INTEGER,

    -- Logs de consola capturados (futuro)
    console_logs JSONB DEFAULT '[]'::JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Índices

```sql
CREATE INDEX idx_cron_log_name ON cron_execution_log(cron_name);
CREATE INDEX idx_cron_log_time ON cron_execution_log(execution_time DESC);
CREATE INDEX idx_cron_log_status ON cron_execution_log(status);
CREATE INDEX idx_cron_log_created ON cron_execution_log(created_at DESC);
```

---

## 🔍 Vista: `v_cron_status`

Vista rápida del estado actual de los crons:

```sql
SELECT * FROM v_cron_status;
```

**Resultado:**

| cron_name | last_execution | executions_today | errors_today | obligations_created_today |
|-----------|----------------|------------------|--------------|---------------------------|
| generate-obligations | 2025-12-01 00:00:00 | 1 | 0 | 6 |
| check-notifications | 2025-12-01 21:00:00 | 3 | 0 | 12 |

---

## 📝 Queries Útiles

### Ver últimas 10 ejecuciones

```sql
SELECT
    cron_name,
    execution_time,
    status,
    obligations_created,
    notifications_created,
    execution_duration_ms
FROM cron_execution_log
ORDER BY execution_time DESC
LIMIT 10;
```

### Ver ejecuciones de hoy

```sql
SELECT
    cron_name,
    execution_time,
    status,
    obligations_created,
    notifications_created
FROM cron_execution_log
WHERE execution_time::DATE = CURRENT_DATE
ORDER BY execution_time DESC;
```

### Ver solo errores

```sql
SELECT
    cron_name,
    execution_time,
    error_message,
    details
FROM cron_execution_log
WHERE status = 'error'
ORDER BY execution_time DESC;
```

### Estadísticas de últimos 7 días

```sql
SELECT
    cron_name,
    DATE(execution_time) as day,
    COUNT(*) as executions,
    SUM(obligations_created) as total_obligations,
    SUM(notifications_created) as total_notifications
FROM cron_execution_log
WHERE execution_time >= NOW() - INTERVAL '7 days'
GROUP BY cron_name, DATE(execution_time)
ORDER BY day DESC, cron_name;
```

### ¿Se ejecutó hoy?

```sql
SELECT
    CASE
        WHEN COUNT(*) > 0 THEN '✅ SÍ'
        ELSE '❌ NO'
    END as ejecutado_hoy,
    MAX(execution_time) as ultima_ejecucion
FROM cron_execution_log
WHERE cron_name = 'generate-obligations'
  AND execution_time::DATE = CURRENT_DATE;
```

---

## 📁 Archivo de Queries

Todas las queries útiles están en:

```
scripts/database/CRON_MONITORING_QUERIES.sql
```

**Incluye 10 secciones:**
1. Últimas ejecuciones
2. Ejecuciones con errores
3. Estadísticas generales
4. Actividad reciente
5. Detección de problemas
6. Análisis de obligaciones
7. Análisis de notificaciones
8. Verificación de salud (Health Check)
9. Limpieza de logs antiguos
10. Queries rápidas

---

## 🚀 Cómo se Guarda Automáticamente

### Implementación en los Endpoints

Ambos endpoints (`generate-obligations` y `check-notifications`) guardan automáticamente cada ejecución:

```typescript
export async function GET(request: Request) {
  const startTime = Date.now();
  let supabase: any = null;

  try {
    // ... código del cron ...

    if (error) {
      // Guardar error
      await supabase.from('cron_execution_log').insert({
        cron_name: 'generate-obligations',
        execution_time: now.toISOString(),
        status: 'error',
        error_message: error.message,
        details: error,
        execution_duration_ms: Date.now() - startTime,
      });
      return new Response(...);
    }

    // Guardar success
    await supabase.from('cron_execution_log').insert({
      cron_name: 'generate-obligations',
      execution_time: now.toISOString(),
      status: 'success',
      obligations_created: totalCreated,
      obligations_skipped: totalSkipped,
      companies_processed: results.length,
      details: response,
      execution_duration_ms: Date.now() - startTime,
    });

  } catch (error) {
    // Guardar exception
    if (supabase) {
      await supabase.from('cron_execution_log').insert({
        cron_name: 'generate-obligations',
        execution_time: new Date().toISOString(),
        status: 'error',
        error_message: error.message,
        execution_duration_ms: Date.now() - startTime,
      });
    }
  }
}
```

---

## 🎯 Escenarios de Uso

### 1. Debugging: "¿Por qué no se crearon obligaciones?"

```sql
-- Ver última ejecución del cron
SELECT
    execution_time,
    status,
    obligations_created,
    obligations_skipped,
    companies_processed,
    error_message,
    details
FROM cron_execution_log
WHERE cron_name = 'generate-obligations'
ORDER BY execution_time DESC
LIMIT 1;
```

**Si `obligations_created = 0` y `obligations_skipped > 0`:**
→ Las obligaciones ya existen (normal si se ejecuta diariamente)

**Si `status = 'error':**
→ Revisar `error_message` y `details`

### 2. Monitoreo: "¿Están funcionando los crons?"

```sql
SELECT * FROM v_cron_status;
```

**Verificar:**
- ✅ `last_execution` es reciente
- ✅ `errors_today = 0`
- ✅ `executions_today > 0`

### 3. Análisis: "¿Cuántas obligaciones se crean al mes?"

```sql
SELECT
    DATE_TRUNC('month', execution_time) as month,
    SUM(obligations_created) as total_created,
    COUNT(*) as executions
FROM cron_execution_log
WHERE cron_name = 'generate-obligations'
  AND execution_time >= NOW() - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', execution_time)
ORDER BY month DESC;
```

### 4. Performance: "¿Algún cron está lento?"

```sql
SELECT
    cron_name,
    execution_time,
    execution_duration_ms,
    ROUND(execution_duration_ms / 1000.0, 2) as seconds
FROM cron_execution_log
WHERE execution_duration_ms > 5000  -- Más de 5 segundos
ORDER BY execution_duration_ms DESC
LIMIT 10;
```

---

## ⚠️ Detección de Problemas

### Detectar días sin ejecución

```sql
-- Días de los últimos 30 donde NO se ejecutó el cron
WITH expected_dates AS (
    SELECT generate_series(
        DATE_TRUNC('day', NOW() - INTERVAL '30 days'),
        DATE_TRUNC('day', NOW()),
        INTERVAL '1 day'
    )::DATE as day
)
SELECT ed.day
FROM expected_dates ed
LEFT JOIN cron_execution_log cel
    ON DATE(cel.execution_time) = ed.day
    AND cel.cron_name = 'generate-obligations'
WHERE cel.id IS NULL
ORDER BY ed.day DESC;
```

**Si hay días sin ejecución → Problema con Vercel Cron**

### Tasa de éxito

```sql
SELECT
    cron_name,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE status = 'success') as successful,
    COUNT(*) FILTER (WHERE status = 'error') as failed,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'success') / COUNT(*), 2) as success_rate_pct
FROM cron_execution_log
WHERE execution_time >= NOW() - INTERVAL '30 days'
GROUP BY cron_name;
```

**Si `success_rate_pct < 95%` → Investigar errores**

---

## 🧹 Mantenimiento

### Limpieza de Logs Antiguos (Opcional)

```sql
-- Ver tamaño de la tabla
SELECT pg_size_pretty(pg_total_relation_size('cron_execution_log'));

-- Contar logs por mes
SELECT
    TO_CHAR(execution_time, 'YYYY-MM') as month,
    COUNT(*) as total_logs,
    COUNT(*) FILTER (WHERE status = 'error') as errors
FROM cron_execution_log
GROUP BY TO_CHAR(execution_time, 'YYYY-MM')
ORDER BY month DESC;

-- Borrar logs exitosos > 90 días (mantener errores)
-- PRECAUCIÓN: Solo ejecutar si la tabla está muy grande
DELETE FROM cron_execution_log
WHERE execution_time < NOW() - INTERVAL '90 days'
  AND status = 'success';
```

---

## 📊 Dashboard (Futuro)

Los datos de `cron_execution_log` pueden usarse para crear un dashboard en la app:

```typescript
// Componente React Native
const { data } = await supabase
  .from('cron_execution_log')
  .select('*')
  .order('execution_time', { ascending: false })
  .limit(10);
```

O usar la vista:

```typescript
const { data } = await supabase
  .from('v_cron_status')
  .select('*');
```

---

## ✅ Checklist de Verificación

Después del deploy, verifica:

```
[ ] 1. Tabla cron_execution_log existe en Supabase
[ ] 2. Vista v_cron_status existe
[ ] 3. Los crons se ejecutan (ver Vercel Dashboard)
[ ] 4. Se guardan logs en Supabase:
        SELECT COUNT(*) FROM cron_execution_log;
[ ] 5. No hay errores recientes:
        SELECT * FROM cron_execution_log WHERE status = 'error';
[ ] 6. Ambos crons ejecutaron hoy:
        SELECT * FROM v_cron_status;
```

---

## 🔗 Archivos Relacionados

- **Tabla:** `scripts/database/COMPLETE_SETUP.sql` (PART 11)
- **Vista:** `scripts/database/COMPLETE_SETUP.sql` (PART 14)
- **Queries:** `scripts/database/CRON_MONITORING_QUERIES.sql`
- **Endpoint 1:** `app/api/cron/generate-obligations+api.ts`
- **Endpoint 2:** `app/api/cron/check-notifications+api.ts`

---

**Última actualización:** 2025-11-30
