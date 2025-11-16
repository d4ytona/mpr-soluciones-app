-- ============================================================
-- GENERATE_2025_OBLIGATIONS.sql
-- ============================================================
-- Generates all monthly obligations for 2025 (January - November)
-- Run this AFTER COMPLETE_SETUP.sql
-- ============================================================

-- First, recreate the function with the correct type casting
CREATE OR REPLACE FUNCTION public.fn_generate_monthly_obligations(
    p_company_id BIGINT DEFAULT NULL,
    p_year INTEGER DEFAULT EXTRACT(YEAR FROM NOW())::INTEGER,
    p_month INTEGER DEFAULT EXTRACT(MONTH FROM NOW())::INTEGER
)
RETURNS TABLE (
    obligations_created INTEGER,
    obligations_skipped INTEGER,
    company_name TEXT,
    details JSONB
) AS $$
DECLARE
    v_config RECORD;
    v_due_date DATE;
    v_created_count INTEGER := 0;
    v_skipped_count INTEGER := 0;
    v_company_name TEXT;
    v_obligation_exists BOOLEAN;
BEGIN
    IF p_month < 1 OR p_month > 12 THEN
        RAISE EXCEPTION 'Invalid month: %. Must be between 1 and 12.', p_month;
    END IF;

    FOR v_config IN
        SELECT
            moc.id,
            moc.company_id,
            moc.document_type_id,
            moc.frequency,
            moc.due_day,
            c.name::TEXT as company_name,
            dt.name as document_type_name
        FROM public.monthly_obligations_config moc
        JOIN public.companies c ON moc.company_id = c.id
        JOIN public.document_types dt ON moc.document_type_id = dt.id
        WHERE moc.active = TRUE
          AND moc.enabled = TRUE
          AND c.active = TRUE
          AND (p_company_id IS NULL OR moc.company_id = p_company_id)
    LOOP
        IF v_config.frequency = 'quarterly' AND p_month NOT IN (3, 6, 9, 12) THEN
            CONTINUE;
        END IF;

        IF v_config.frequency = 'annual' AND p_month != 12 THEN
            CONTINUE;
        END IF;

        v_due_date := make_date(
            p_year,
            p_month,
            LEAST(v_config.due_day, extract(day from date_trunc('month', make_date(p_year, p_month, 1)) + interval '1 month - 1 day')::INTEGER)
        ) + interval '1 month';

        SELECT EXISTS(
            SELECT 1 FROM public.output_documents
            WHERE company_id = v_config.company_id
              AND document_type_id = v_config.document_type_id
              AND period_year = p_year
              AND period_month = p_month
              AND active = TRUE
        ) INTO v_obligation_exists;

        IF v_obligation_exists THEN
            v_skipped_count := v_skipped_count + 1;
            CONTINUE;
        END IF;

        INSERT INTO public.output_documents (
            company_id,
            document_type_id,
            uploaded_by,
            file_url,
            notes,
            due_date,
            source_input_document_ids,
            period_year,
            period_month,
            obligation_status,
            auto_generated
        ) VALUES (
            v_config.company_id,
            v_config.document_type_id,
            NULL,
            NULL,
            format('Auto-generated %s obligation for %s %s',
                   v_config.frequency,
                   to_char(make_date(p_year, p_month, 1), 'Month'),
                   p_year),
            v_due_date,
            ARRAY[]::BIGINT[],
            p_year,
            p_month,
            'pending',
            TRUE
        );

        v_created_count := v_created_count + 1;
    END LOOP;

    RETURN QUERY
    SELECT
        v_created_count,
        v_skipped_count,
        COALESCE((SELECT name::TEXT FROM public.companies WHERE id = p_company_id), 'All Companies'),
        jsonb_build_object(
            'year', p_year,
            'month', p_month,
            'period', to_char(make_date(p_year, p_month, 1), 'Month YYYY')
        );
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Generate obligations for all months of 2025
-- ============================================================

DO $$
DECLARE
    v_month INTEGER;
    v_result RECORD;
    v_total_created INTEGER := 0;
    v_total_skipped INTEGER := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Generating 2025 Obligations';
    RAISE NOTICE 'January - November 2025';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';

    FOR v_month IN 1..11 LOOP
        RAISE NOTICE '----------------------------------------';
        RAISE NOTICE 'Processing: % 2025', to_char(make_date(2025, v_month, 1), 'Month');
        RAISE NOTICE '----------------------------------------';

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
    RAISE NOTICE '  - Check pending: SELECT * FROM v_documents_pending_review;';
    RAISE NOTICE '========================================';
END $$;

-- ============================================================
-- Summary Queries
-- ============================================================

-- Obligation Summary by Month
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

-- Obligation Summary by Company
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
