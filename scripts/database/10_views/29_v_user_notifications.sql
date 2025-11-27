-- 29_v_user_notifications.sql
-- ============================================================
-- Description: View for user notifications with joined data
--              from companies, obligations, and document types.
-- ============================================================

DROP VIEW IF EXISTS public.v_user_notifications CASCADE;

CREATE VIEW public.v_user_notifications AS
SELECT
    n.id,
    n.user_id,
    n.title,
    n.message,
    n.obligation_id,
    n.company_id,
    n.notification_type,
    n.is_read,
    n.created_at,

    -- Company information
    c.name as company_name,
    c.tax_id as company_tax_id,

    -- Obligation information
    dt.name as obligation_type,
    od.period_year,
    od.period_month,
    od.due_date,
    od.obligation_status

FROM public.notifications n
LEFT JOIN public.companies c ON n.company_id = c.id
LEFT JOIN public.output_documents od ON n.obligation_id = od.id
LEFT JOIN public.document_types dt ON od.document_type_id = dt.id
WHERE n.active = TRUE
ORDER BY n.created_at DESC;

-- Usage:
-- Get all unread notifications for a user:
-- SELECT * FROM v_user_notifications WHERE user_id = 1 AND is_read = FALSE;

-- Get notifications by type:
-- SELECT * FROM v_user_notifications WHERE user_id = 1 AND notification_type = 'new_obligation';

-- Get notifications for a specific company:
-- SELECT * FROM v_user_notifications WHERE user_id = 1 AND company_id = 3;
