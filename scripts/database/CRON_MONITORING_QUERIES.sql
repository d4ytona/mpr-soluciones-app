-- ============================================================
-- CRON MONITORING QUERIES
-- ============================================================
-- Queries útiles para monitorear y debuggear los cron jobs
-- Ejecutar en Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. ÚLTIMAS EJECUCIONES
-- ============================================================

-- Ver últimas 20 ejecuciones de todos los crons
SELECT
    id,
    cron_name,
    execution_time,
    status,
    obligations_created,
    obligations_skipped,
    notifications_created,
    obligations_checked,
    execution_duration_ms,
    error_message
FROM cron_execution_log
ORDER BY execution_time DESC
LIMIT 20;

-- Ver última ejecución de cada cron
SELECT DISTINCT ON (cron_name)
    cron_name,
    execution_time,
    status,
    obligations_created,
    notifications_created,
    execution_duration_ms,
    error_message
FROM cron_execution_log
ORDER BY cron_name, execution_time DESC;

-- ============================================================
-- 2. EJECUCIONES CON ERRORES
-- ============================================================

-- Ver todos los errores
SELECT
    id,
    cron_name,
    execution_time,
    error_message,
    details,
    execution_duration_ms
FROM cron_execution_log
WHERE status = 'error'
ORDER BY execution_time DESC;

-- Contar errores por cron
SELECT
    cron_name,
    COUNT(*) as total_errors,
    MAX(execution_time) as last_error
FROM cron_execution_log
WHERE status = 'error'
GROUP BY cron_name
ORDER BY total_errors DESC;

-- Errores de las últimas 24 horas
SELECT
    cron_name,
    execution_time,
    error_message,
    details
FROM cron_execution_log
WHERE status = 'error'
  AND execution_time >= NOW() - INTERVAL '24 hours'
ORDER BY execution_time DESC;

-- ============================================================
-- 3. ESTADÍSTICAS GENERALES
-- ============================================================

-- Estadísticas de últimos 7 días
SELECT
    cron_name,
    DATE(execution_time) as day,
    COUNT(*) as executions,
    COUNT(*) FILTER (WHERE status = 'success') as successful,
    COUNT(*) FILTER (WHERE status = 'error') as failed,
    SUM(obligations_created) as total_obligations,
    SUM(notifications_created) as total_notifications,
    AVG(execution_duration_ms) as avg_duration_ms,
    MAX(execution_duration_ms) as max_duration_ms
FROM cron_execution_log
WHERE execution_time >= NOW() - INTERVAL '7 days'
GROUP BY cron_name, DATE(execution_time)
ORDER BY day DESC, cron_name;

-- Resumen general (todas las ejecuciones)
SELECT
    cron_name,
    COUNT(*) as total_executions,
    COUNT(*) FILTER (WHERE status = 'success') as successful,
    COUNT(*) FILTER (WHERE status = 'error') as failed,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'success') / COUNT(*), 2) as success_rate,
    SUM(obligations_created) as total_obligations_created,
    SUM(notifications_created) as total_notifications_created,
    AVG(execution_duration_ms) as avg_duration_ms
FROM cron_execution_log
GROUP BY cron_name;

-- ============================================================
-- 4. ACTIVIDAD RECIENTE
-- ============================================================

-- Ejecuciones de hoy
SELECT
    cron_name,
    execution_time,
    status,
    obligations_created,
    obligations_skipped,
    notifications_created,
    obligations_checked,
    execution_duration_ms
FROM cron_execution_log
WHERE execution_time::DATE = CURRENT_DATE
ORDER BY execution_time DESC;

-- Resumen de hoy por cron
SELECT
    cron_name,
    COUNT(*) as executions_today,
    COUNT(*) FILTER (WHERE status = 'success') as successful,
    COUNT(*) FILTER (WHERE status = 'error') as errors,
    SUM(obligations_created) as obligations_today,
    SUM(notifications_created) as notifications_today,
    MAX(execution_time) as last_execution
FROM cron_execution_log
WHERE execution_time::DATE = CURRENT_DATE
GROUP BY cron_name;

-- ============================================================
-- 5. DETECCIÓN DE PROBLEMAS
-- ============================================================

-- Detectar días donde NO se ejecutó generate-obligations
WITH expected_dates AS (
    SELECT generate_series(
        DATE_TRUNC('day', NOW() - INTERVAL '30 days'),
        DATE_TRUNC('day', NOW()),
        INTERVAL '1 day'
    )::DATE as day
)
SELECT
    ed.day,
    COALESCE(COUNT(cel.id), 0) as executions
FROM expected_dates ed
LEFT JOIN cron_execution_log cel
    ON DATE(cel.execution_time) = ed.day
    AND cel.cron_name = 'generate-obligations'
GROUP BY ed.day
HAVING COUNT(cel.id) = 0
ORDER BY ed.day DESC;

-- Detectar ejecuciones que tardaron mucho (> 10 segundos)
SELECT
    cron_name,
    execution_time,
    execution_duration_ms,
    ROUND(execution_duration_ms / 1000.0, 2) as duration_seconds,
    status,
    obligations_created,
    notifications_created
FROM cron_execution_log
WHERE execution_duration_ms > 10000
ORDER BY execution_duration_ms DESC
LIMIT 20;

-- ============================================================
-- 6. ANÁLISIS DE OBLIGACIONES
-- ============================================================

-- Obligaciones creadas por día (últimos 30 días)
SELECT
    DATE(execution_time) as day,
    SUM(obligations_created) as total_created,
    SUM(obligations_skipped) as total_skipped,
    COUNT(DISTINCT CASE WHEN obligations_created > 0 THEN id END) as days_with_creation
FROM cron_execution_log
WHERE cron_name = 'generate-obligations'
  AND execution_time >= NOW() - INTERVAL '30 days'
GROUP BY DATE(execution_time)
ORDER BY day DESC;

-- Empresas procesadas por ejecución
SELECT
    execution_time,
    companies_processed,
    obligations_created,
    obligations_skipped,
    ROUND(obligations_created::NUMERIC / NULLIF(companies_processed, 0), 2) as avg_per_company
FROM cron_execution_log
WHERE cron_name = 'generate-obligations'
  AND companies_processed > 0
ORDER BY execution_time DESC
LIMIT 20;

-- ============================================================
-- 7. ANÁLISIS DE NOTIFICACIONES
-- ============================================================

-- Notificaciones creadas por día
SELECT
    DATE(execution_time) as day,
    COUNT(*) as executions,
    SUM(notifications_created) as total_notifications,
    SUM(obligations_checked) as total_checked,
    ROUND(AVG(notifications_created), 2) as avg_notifications_per_run
FROM cron_execution_log
WHERE cron_name = 'check-notifications'
  AND execution_time >= NOW() - INTERVAL '7 days'
GROUP BY DATE(execution_time)
ORDER BY day DESC;

-- Notificaciones por hora del día (patrón)
SELECT
    EXTRACT(HOUR FROM execution_time) as hour,
    COUNT(*) as executions,
    SUM(notifications_created) as total_notifications,
    ROUND(AVG(notifications_created), 2) as avg_notifications
FROM cron_execution_log
WHERE cron_name = 'check-notifications'
  AND execution_time >= NOW() - INTERVAL '7 days'
GROUP BY EXTRACT(HOUR FROM execution_time)
ORDER BY hour;

-- ============================================================
-- 8. VERIFICACIÓN DE SALUD (HEALTH CHECK)
-- ============================================================

-- Estado actual de todos los crons (usando la vista)
SELECT * FROM v_cron_status;

-- Verificar que ambos crons se ejecutaron hoy
SELECT
    cron_name,
    EXISTS(
        SELECT 1 FROM cron_execution_log
        WHERE cron_name = cel.cron_name
          AND execution_time::DATE = CURRENT_DATE
          AND status = 'success'
    ) as executed_today
FROM (
    SELECT 'generate-obligations' as cron_name
    UNION ALL
    SELECT 'check-notifications'
) cel;

-- ============================================================
-- 9. LIMPIEZA DE LOGS ANTIGUOS (Opcional)
-- ============================================================

-- Ver cuántos logs hay por mes
SELECT
    TO_CHAR(execution_time, 'YYYY-MM') as month,
    COUNT(*) as total_logs,
    COUNT(*) FILTER (WHERE status = 'error') as errors,
    pg_size_pretty(pg_total_relation_size('cron_execution_log')) as table_size
FROM cron_execution_log
GROUP BY TO_CHAR(execution_time, 'YYYY-MM')
ORDER BY month DESC;

-- PRECAUCIÓN: Borrar logs más antiguos de 90 días (ejecutar solo si necesario)
-- DELETE FROM cron_execution_log
-- WHERE execution_time < NOW() - INTERVAL '90 days'
--   AND status = 'success';  -- Solo borrar los exitosos, mantener errores

-- ============================================================
-- 10. QUERIES RÁPIDAS
-- ============================================================

-- ¿El cron de obligaciones se ejecutó hoy?
SELECT
    CASE
        WHEN COUNT(*) > 0 THEN '✅ SÍ se ejecutó hoy'
        ELSE '❌ NO se ha ejecutado hoy'
    END as status,
    MAX(execution_time) as last_execution
FROM cron_execution_log
WHERE cron_name = 'generate-obligations'
  AND execution_time::DATE = CURRENT_DATE;

-- ¿Cuándo fue la última vez que creó obligaciones?
SELECT
    execution_time,
    obligations_created,
    companies_processed
FROM cron_execution_log
WHERE cron_name = 'generate-obligations'
  AND obligations_created > 0
ORDER BY execution_time DESC
LIMIT 1;

-- ¿Hubo errores en las últimas 24 horas?
SELECT
    COUNT(*) as total_errors,
    STRING_AGG(DISTINCT cron_name, ', ') as affected_crons
FROM cron_execution_log
WHERE status = 'error'
  AND execution_time >= NOW() - INTERVAL '24 hours';
