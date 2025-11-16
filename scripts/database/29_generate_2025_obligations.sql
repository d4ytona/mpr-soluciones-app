-- 29_generate_2025_obligations.sql
-- ============================================================
-- Description: Generates all monthly obligations for 2025 (January - November).
--              Run this after database setup to populate obligations.
-- ============================================================

\echo '========================================='
\echo 'Generating 2025 Obligations'
\echo 'January - November 2025'
\echo '========================================='
\echo ''

-- Generate obligations for each month of 2025 (January through November)
DO $$
DECLARE
    v_month INTEGER;
    v_result RECORD;
    v_total_created INTEGER := 0;
    v_total_skipped INTEGER := 0;
BEGIN
    FOR v_month IN 1..11 LOOP
        RAISE NOTICE '----------------------------------------';
        RAISE NOTICE 'Processing: % 2025', to_char(make_date(2025, v_month, 1), 'Month');
        RAISE NOTICE '----------------------------------------';

        -- Generate obligations for this month
        FOR v_result IN
            SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, v_month)
        LOOP
            RAISE NOTICE 'Company: %', v_result.company_name;
            RAISE NOTICE 'Created: % obligations', v_result.obligations_created;
            RAISE NOTICE 'Skipped: % obligations', v_result.obligations_skipped;

            v_total_created := v_total_created + v_result.obligations_created;
            v_total_skipped := v_total_skipped + v_result.obligations_skipped;
        END LOOP;

        RAISE NOTICE '';
    END LOOP;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Generation Complete!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Total obligations created: %', v_total_created;
    RAISE NOTICE 'Total obligations skipped: %', v_total_skipped;
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '  - View dashboard: SELECT * FROM v_obligations_dashboard;';
    RAISE NOTICE '  - Check pending: SELECT * FROM v_documents_pending_review WHERE doc_category = ''obligation'';';
    RAISE NOTICE '========================================';
END $$;

-- Quick summary query
\echo ''
\echo 'Obligation Summary by Month:'
\echo ''

SELECT
    period_year,
    period_month,
    to_char(make_date(period_year, period_month, 1), 'Month YYYY') as period,
    COUNT(*) as total_obligations,
    COUNT(*) FILTER (WHERE obligation_status = 'pending') as pending,
    COUNT(*) FILTER (WHERE obligation_status = 'in_progress') as in_progress,
    COUNT(*) FILTER (WHERE obligation_status = 'completed') as completed,
    COUNT(*) FILTER (WHERE obligation_status = 'overdue') as overdue
FROM output_documents
WHERE auto_generated = TRUE
  AND active = TRUE
GROUP BY period_year, period_month
ORDER BY period_year, period_month;

\echo ''
\echo 'Obligation Summary by Company:'
\echo ''

SELECT
    c.name as company_name,
    COUNT(*) as total_obligations,
    COUNT(*) FILTER (WHERE od.obligation_status = 'pending') as pending,
    COUNT(*) FILTER (WHERE od.obligation_status = 'completed') as completed
FROM output_documents od
JOIN companies c ON od.company_id = c.id
WHERE od.auto_generated = TRUE
  AND od.active = TRUE
GROUP BY c.name
ORDER BY c.name;
