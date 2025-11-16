-- 27_v_documents_pending_review.sql
-- ============================================================
-- Description: Documents requiring attention (expiring legal docs and due obligations).
-- ============================================================

DROP VIEW IF EXISTS public.v_documents_pending_review CASCADE;

CREATE VIEW public.v_documents_pending_review AS
-- Legal documents expiring soon
SELECT
    'legal' as doc_category,
    ld.id as document_id,
    c.id as company_id,
    c.name as company_name,
    dt.id as document_type_id,
    dt.name as document_type,
    ld.file_url,
    ld.expiration_date as important_date,
    ld.expiration_date - CURRENT_DATE as days_remaining,
    CASE
        WHEN ld.expiration_date < CURRENT_DATE THEN 'expired'
        WHEN ld.expiration_date - CURRENT_DATE <= 7 THEN 'critical'
        WHEN ld.expiration_date - CURRENT_DATE <= 30 THEN 'warning'
        ELSE 'normal'
    END as alert_level,
    ld.created_at,
    ld.updated_at
FROM public.legal_documents ld
JOIN public.companies c ON ld.company_id = c.id
JOIN public.document_types dt ON ld.document_type_id = dt.id
WHERE ld.active = TRUE
  AND c.active = TRUE
  AND ld.expiration_date IS NOT NULL
  AND ld.expiration_date < CURRENT_DATE + INTERVAL '30 days'

UNION ALL

-- Output obligations due soon
SELECT
    'obligation' as doc_category,
    od.id as document_id,
    c.id as company_id,
    c.name as company_name,
    dt.id as document_type_id,
    dt.name as document_type,
    od.file_url,
    od.due_date as important_date,
    od.due_date - CURRENT_DATE as days_remaining,
    CASE
        WHEN od.due_date < CURRENT_DATE THEN 'overdue'
        WHEN od.due_date - CURRENT_DATE <= 3 THEN 'critical'
        WHEN od.due_date - CURRENT_DATE <= 7 THEN 'warning'
        ELSE 'normal'
    END as alert_level,
    od.created_at,
    od.updated_at
FROM public.output_documents od
JOIN public.companies c ON od.company_id = c.id
JOIN public.document_types dt ON od.document_type_id = dt.id
WHERE od.active = TRUE
  AND c.active = TRUE
  AND od.auto_generated = TRUE
  AND od.obligation_status != 'completed'
  AND od.due_date < CURRENT_DATE + INTERVAL '15 days'

ORDER BY days_remaining ASC;

-- Usage:
-- SELECT * FROM v_documents_pending_review WHERE alert_level IN ('critical', 'overdue', 'expired');
-- SELECT * FROM v_documents_pending_review WHERE company_id = 1;
-- SELECT COUNT(*), alert_level FROM v_documents_pending_review GROUP BY alert_level;
