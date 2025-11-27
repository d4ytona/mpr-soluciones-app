-- ============================================================
-- GENERATE_OBLIGATIONS.sql
-- ============================================================
-- MPR Soluciones - Generate Obligations Script
-- Generates monthly, quarterly, and annual obligations
-- for all companies or a specific company.
--
-- Usage:
-- 1. For all companies (current month):
--    SELECT * FROM fn_generate_monthly_obligations();
--
-- 2. For specific company (current month):
--    SELECT * FROM fn_generate_monthly_obligations(1);
--
-- 3. For specific month/year:
--    SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, 11);
--
-- 4. For range of months (example: generate Jan-Dec 2025):
--    SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, month)
--    FROM generate_series(1, 12) as month;
-- ============================================================

\echo '';
\echo '========================================';
\echo 'OBLIGATION GENERATION';
\echo '========================================';
\echo '';
\echo 'This script will generate obligations based on';
\echo 'configurations in monthly_obligations_config table.';
\echo '';
\echo 'Current configurations:';
\echo '';

-- Display current obligation configurations
SELECT
    c.name as company_name,
    dt.name as obligation_type,
    moc.frequency,
    moc.due_day,
    moc.enabled,
    moc.notes
FROM monthly_obligations_config moc
JOIN companies c ON moc.company_id = c.id
JOIN document_types dt ON moc.document_type_id = dt.id
WHERE moc.active = TRUE
  AND c.active = TRUE
ORDER BY c.name, moc.frequency, dt.name;

\echo '';
\echo '========================================';
\echo 'GENERATING OBLIGATIONS';
\echo '========================================';
\echo '';

-- ============================================================
-- OPTION 1: Generate for ALL companies (current month)
-- ============================================================
-- Uncomment to run:
-- SELECT * FROM fn_generate_monthly_obligations();

-- ============================================================
-- OPTION 2: Generate for specific company (current month)
-- ============================================================
-- Replace <company_id> with actual company ID
-- Uncomment to run:
-- SELECT * FROM fn_generate_monthly_obligations(1);

-- ============================================================
-- OPTION 3: Generate for specific month/year
-- ============================================================
-- Parameters: (company_id, year, month)
-- NULL for company_id = all companies
-- Uncomment and modify to run:
-- SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, 12);

-- ============================================================
-- OPTION 4: Generate for range of months (bulk generation)
-- ============================================================
-- Example: Generate obligations for January to December 2025
-- Uncomment to run:
/*
SELECT
    month,
    obligations_created,
    obligations_skipped,
    company_name,
    details
FROM fn_generate_monthly_obligations(NULL, 2025, month)
CROSS JOIN generate_series(1, 12) as month
ORDER BY month;
*/

-- ============================================================
-- OPTION 5: Regenerate obligations (with force delete)
-- ============================================================
-- Use this to regenerate obligations for a specific period
-- WARNING: This will DELETE existing auto-generated obligations
-- Parameters: (company_id, year, month, force_delete)
-- Uncomment and modify to run:
-- SELECT * FROM fn_regenerate_obligations(1, 2025, 11, TRUE);

\echo '';
\echo '========================================';
\echo 'INSTRUCTIONS';
\echo '========================================';
\echo '';
\echo 'Uncomment one of the OPTIONS above and run again.';
\echo '';
\echo 'After generation, verify with:';
\echo '  SELECT * FROM v_obligations_dashboard;';
\echo '';
\echo 'To check what was created:';
\echo '  SELECT * FROM output_documents';
\echo '  WHERE auto_generated = TRUE';
\echo '  ORDER BY created_at DESC;';
\echo '';
\echo '========================================';
