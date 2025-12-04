-- 22_fn_generate_monthly_obligations.sql
-- ============================================================
-- Description: Automatically generates monthly obligations based on config.
--              Can generate for all companies or a specific one.
-- ============================================================

CREATE OR REPLACE FUNCTION public.fn_generate_monthly_obligations(
    p_company_id BIGINT DEFAULT NULL,           -- NULL = all companies, or specific company ID
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
    -- Validate month
    IF p_month < 1 OR p_month > 12 THEN
        RAISE EXCEPTION 'Invalid month: %. Must be between 1 and 12.', p_month;
    END IF;

    -- Loop through all enabled obligation configurations
    FOR v_config IN
        SELECT
            moc.id,
            moc.company_id,
            moc.document_type_id,
            moc.frequency,
            moc.due_day,
            c.name as company_name,
            dt.name as document_type_name
        FROM public.obligations_config moc
        JOIN public.companies c ON moc.company_id = c.id
        JOIN public.document_types dt ON moc.document_type_id = dt.id
        WHERE moc.active = TRUE
          AND moc.enabled = TRUE
          AND c.active = TRUE
          AND (p_company_id IS NULL OR moc.company_id = p_company_id)
    LOOP
        -- Skip if frequency doesn't match current period
        IF v_config.frequency = 'quarterly' AND p_month NOT IN (3, 6, 9, 12) THEN
            CONTINUE;
        END IF;

        IF v_config.frequency = 'annual' AND p_month != 12 THEN
            CONTINUE;
        END IF;

        -- Calculate due date
        -- Due date is in the NEXT month after the period
        -- For example: January obligations are due in February
        v_due_date := make_date(
            p_year,
            p_month,
            LEAST(v_config.due_day, extract(day from date_trunc('month', make_date(p_year, p_month, 1)) + interval '1 month - 1 day')::INTEGER)
        ) + interval '1 month';

        -- Check if obligation already exists
        SELECT EXISTS(
            SELECT 1 FROM public.output_documents
            WHERE company_id = v_config.company_id
              AND document_type_id = v_config.document_type_id
              AND period_year = p_year
              AND period_month = p_month
              AND active = TRUE
        ) INTO v_obligation_exists;

        -- Skip if already exists
        IF v_obligation_exists THEN
            v_skipped_count := v_skipped_count + 1;
            CONTINUE;
        END IF;

        -- Create the obligation
        INSERT INTO public.output_documents (
            company_id,
            document_type_id,
            uploaded_by,
            file_url,
            notes,
            due_date,
            period_year,
            period_month,
            obligation_status,
            auto_generated
        ) VALUES (
            v_config.company_id,
            v_config.document_type_id,
            NULL,  -- No uploader yet (auto-generated)
            NULL,  -- No file yet
            format('Auto-generated %s obligation for %s %s',
                   v_config.frequency,
                   to_char(make_date(p_year, p_month, 1), 'Month'),
                   p_year),
            v_due_date,
            p_year,
            p_month,
            'pending',
            TRUE
        );

        v_created_count := v_created_count + 1;
    END LOOP;

    -- Return summary
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

-- Usage examples:
-- Generate for all companies for current month:
-- SELECT * FROM fn_generate_monthly_obligations();

-- Generate for specific company and month:
-- SELECT * FROM fn_generate_monthly_obligations(1, 2025, 1);

-- Generate for all companies for entire year 2025:
-- SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, generate_series(1, 12));
