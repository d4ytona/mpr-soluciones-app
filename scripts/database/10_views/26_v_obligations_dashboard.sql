-- 26_v_obligations_dashboard.sql
-- ============================================================
-- Description: Complete obligation dashboard with status, dates, and details.
-- ============================================================

DROP VIEW IF EXISTS public.v_obligations_dashboard CASCADE;

CREATE VIEW public.v_obligations_dashboard AS
SELECT
    od.id as obligation_id,
    od.company_id,
    c.name as company_name,
    c.tax_id,

    od.document_type_id,
    dt.name as obligation_name,
    dt.code as obligation_code,

    -- Period information
    od.period_year,
    od.period_month,
    to_char(make_date(od.period_year, od.period_month, 1), 'Month YYYY') as period_formatted,

    -- Due date and status
    od.due_date,
    od.due_date - CURRENT_DATE as days_until_due,
    od.obligation_status,

    -- Document information
    od.file_url,
    od.uploaded_by,
    u.first_name || ' ' || u.last_name as uploaded_by_name,

    -- Related input documents
    od.source_input_document_ids,
    COALESCE(array_length(od.source_input_document_ids, 1), 0) as related_inputs_count,

    -- Metadata
    od.auto_generated,
    od.notes,
    od.created_at,
    od.updated_at,

    -- Status indicators
    CASE
        WHEN od.obligation_status = 'completed' THEN 'completed'
        WHEN od.due_date < CURRENT_DATE THEN 'overdue'
        WHEN od.due_date - CURRENT_DATE <= 7 THEN 'urgent'
        WHEN od.due_date - CURRENT_DATE <= 15 THEN 'soon'
        ELSE 'normal'
    END as urgency_level

FROM public.output_documents od
JOIN public.companies c ON od.company_id = c.id
JOIN public.document_types dt ON od.document_type_id = dt.id
LEFT JOIN public.users u ON od.uploaded_by = u.id
WHERE od.active = TRUE
  AND od.auto_generated = TRUE
  AND c.active = TRUE
ORDER BY od.due_date ASC;

-- Usage:
-- SELECT * FROM v_obligations_dashboard WHERE urgency_level = 'overdue';
-- SELECT * FROM v_obligations_dashboard WHERE company_id = 1 ORDER BY due_date;
-- SELECT * FROM v_obligations_dashboard WHERE period_year = 2025 AND period_month = 1;
