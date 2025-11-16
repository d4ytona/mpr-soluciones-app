-- 23_fn_regenerate_obligations.sql
-- ============================================================
-- Description: Manually regenerate obligations for a specific company and period.
--              Can force-overwrite existing obligations if needed.
-- ============================================================

CREATE OR REPLACE FUNCTION public.fn_regenerate_obligations(
    p_company_id BIGINT,                        -- Required: specific company ID
    p_year INTEGER,                             -- Required: year to regenerate
    p_month INTEGER,                            -- Required: month to regenerate (1-12)
    p_force BOOLEAN DEFAULT FALSE               -- TRUE = delete and recreate, FALSE = skip existing
)
RETURNS TABLE (
    action TEXT,
    obligations_deleted INTEGER,
    obligations_created INTEGER,
    company_name TEXT,
    details JSONB
) AS $$
DECLARE
    v_deleted_count INTEGER := 0;
    v_created_count INTEGER := 0;
    v_company_name TEXT;
BEGIN
    -- Validate inputs
    IF p_month < 1 OR p_month > 12 THEN
        RAISE EXCEPTION 'Invalid month: %. Must be between 1 and 12.', p_month;
    END IF;

    -- Get company name
    SELECT name INTO v_company_name
    FROM public.companies
    WHERE id = p_company_id AND active = TRUE;

    IF v_company_name IS NULL THEN
        RAISE EXCEPTION 'Company with ID % not found or inactive.', p_company_id;
    END IF;

    -- If force = TRUE, delete existing auto-generated obligations for this period
    IF p_force THEN
        WITH deleted AS (
            DELETE FROM public.output_documents
            WHERE company_id = p_company_id
              AND period_year = p_year
              AND period_month = p_month
              AND auto_generated = TRUE
            RETURNING id
        )
        SELECT COUNT(*) INTO v_deleted_count FROM deleted;

        RAISE NOTICE 'Deleted % existing auto-generated obligations for % %/%',
                     v_deleted_count, v_company_name, p_year, p_month;
    END IF;

    -- Generate new obligations using the main generation function
    SELECT obligations_created INTO v_created_count
    FROM public.fn_generate_monthly_obligations(p_company_id, p_year, p_month);

    -- Return summary
    RETURN QUERY
    SELECT
        CASE
            WHEN p_force THEN 'force_regenerate'
            ELSE 'generate_missing'
        END::TEXT,
        v_deleted_count,
        v_created_count,
        v_company_name,
        jsonb_build_object(
            'company_id', p_company_id,
            'year', p_year,
            'month', p_month,
            'period', to_char(make_date(p_year, p_month, 1), 'Month YYYY'),
            'force', p_force
        );
END;
$$ LANGUAGE plpgsql;

-- Usage examples:
-- Regenerate obligations for company 1, January 2025 (skip if exist):
-- SELECT * FROM fn_regenerate_obligations(1, 2025, 1, FALSE);

-- Force regenerate (delete and recreate) for company 1, January 2025:
-- SELECT * FROM fn_regenerate_obligations(1, 2025, 1, TRUE);

-- Regenerate all months for company 1 in 2025:
-- SELECT * FROM fn_regenerate_obligations(1, 2025, generate_series(1, 12), FALSE);
