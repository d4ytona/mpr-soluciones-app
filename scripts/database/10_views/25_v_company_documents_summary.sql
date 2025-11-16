-- 25_v_company_documents_summary.sql
-- ============================================================
-- Description: Document counts and summary per company.
-- ============================================================

DROP VIEW IF EXISTS public.v_company_documents_summary CASCADE;

CREATE VIEW public.v_company_documents_summary AS
SELECT
    c.id as company_id,
    c.name as company_name,
    c.tax_id,
    c.email,
    c.phone,

    -- Document counts
    COUNT(DISTINCT id.id) as input_docs_count,
    COUNT(DISTINCT ld.id) as legal_docs_count,
    COUNT(DISTINCT od.id) as output_docs_count,
    COUNT(DISTINCT id.id) + COUNT(DISTINCT ld.id) + COUNT(DISTINCT od.id) as total_docs_count,

    -- Obligation counts
    COUNT(DISTINCT CASE WHEN od.auto_generated = TRUE THEN od.id END) as obligations_count,
    COUNT(DISTINCT CASE WHEN od.auto_generated = TRUE AND od.obligation_status = 'pending' THEN od.id END) as pending_obligations,
    COUNT(DISTINCT CASE WHEN od.auto_generated = TRUE AND od.obligation_status = 'overdue' THEN od.id END) as overdue_obligations,

    c.created_at,
    c.updated_at
FROM public.companies c
LEFT JOIN public.input_documents id ON c.id = id.company_id AND id.active = TRUE
LEFT JOIN public.legal_documents ld ON c.id = ld.company_id AND ld.active = TRUE
LEFT JOIN public.output_documents od ON c.id = od.company_id AND od.active = TRUE
WHERE c.active = TRUE
GROUP BY c.id, c.name, c.tax_id, c.email, c.phone, c.created_at, c.updated_at;

-- Usage:
-- SELECT * FROM v_company_documents_summary;
-- SELECT * FROM v_company_documents_summary WHERE overdue_obligations > 0;
