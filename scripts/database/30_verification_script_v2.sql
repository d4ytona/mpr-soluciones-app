-- 30_verification_script_v2.sql
-- ============================================================
-- Description: Complete verification script for NEW database structure.
--              Verifies tables, views, functions, and test data.
-- ============================================================

\echo '========================================'
\echo 'MPR Soluciones - Database Verification'
\echo 'Version 2.0 - Enhanced Structure'
\echo '========================================'
\echo ''

-- ============================================================
-- SECTION 1: TABLE EXISTENCE
-- ============================================================
\echo 'SECTION 1: Verifying Tables...'
\echo ''

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_log')
        THEN '✓ audit_log'
        ELSE '✗ audit_log MISSING'
    END as table_check
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN '✓ users' ELSE '✗ users MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'companies') THEN '✓ companies' ELSE '✗ companies MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'document_types') THEN '✓ document_types' ELSE '✗ document_types MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'input_documents') THEN '✓ input_documents' ELSE '✗ input_documents MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'output_documents') THEN '✓ output_documents (enhanced)' ELSE '✗ output_documents MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'legal_documents') THEN '✓ legal_documents' ELSE '✗ legal_documents MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'monthly_obligations_config') THEN '✓ monthly_obligations_config (NEW)' ELSE '✗ monthly_obligations_config MISSING' END;

\echo ''
\echo 'Expected: 8 tables (7 core + 1 config + 1 audit)'
\echo ''

-- ============================================================
-- SECTION 2: VIEWS EXISTENCE
-- ============================================================
\echo 'SECTION 2: Verifying Views...'
\echo ''

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_user_profiles')
        THEN '✓ v_user_profiles'
        ELSE '✗ v_user_profiles MISSING'
    END as view_check
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_company_documents_summary') THEN '✓ v_company_documents_summary' ELSE '✗ v_company_documents_summary MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_obligations_dashboard') THEN '✓ v_obligations_dashboard' ELSE '✗ v_obligations_dashboard MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_documents_pending_review') THEN '✓ v_documents_pending_review' ELSE '✗ v_documents_pending_review MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_document_relationships') THEN '✓ v_document_relationships' ELSE '✗ v_document_relationships MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'v_document_relationships_detailed') THEN '✓ v_document_relationships_detailed' ELSE '✗ v_document_relationships_detailed MISSING' END;

\echo ''
\echo 'Expected: 6 views'
\echo ''

-- ============================================================
-- SECTION 3: FUNCTIONS EXISTENCE
-- ============================================================
\echo 'SECTION 3: Verifying Functions...'
\echo ''

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_write_audit')
        THEN '✓ fn_write_audit (audit trigger)'
        ELSE '✗ fn_write_audit MISSING'
    END as function_check
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_generate_monthly_obligations') THEN '✓ fn_generate_monthly_obligations (NEW)' ELSE '✗ fn_generate_monthly_obligations MISSING' END
UNION ALL
SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'fn_regenerate_obligations') THEN '✓ fn_regenerate_obligations (NEW)' ELSE '✗ fn_regenerate_obligations MISSING' END;

\echo ''
\echo 'Expected: 3 functions'
\echo ''

-- ============================================================
-- SECTION 4: AUDIT TRIGGERS
-- ============================================================
\echo 'SECTION 4: Verifying Audit Triggers...'
\echo ''

SELECT
    'Trigger: ' || trigger_name || ' on ' || event_object_table as trigger_info
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'trg_audit_%'
ORDER BY event_object_table;

\echo ''
\echo 'Expected: 7 triggers (users, companies, document_types, input_documents, output_documents, legal_documents, monthly_obligations_config)'
\echo ''

-- ============================================================
-- SECTION 5: RECORD COUNTS
-- ============================================================
\echo 'SECTION 5: Verifying Record Counts...'
\echo ''

SELECT
    'users' as table_name,
    COUNT(*) as record_count,
    '3 expected (rachel, jose, mayerling)' as expected
FROM users
UNION ALL
SELECT 'companies', COUNT(*), '3 expected (empresa demo, soluciones integrales, rachel graphics)' FROM companies
UNION ALL
SELECT 'document_types', COUNT(*), '202 expected' FROM document_types
UNION ALL
SELECT 'input_documents', COUNT(*), '9 expected' FROM input_documents
UNION ALL
SELECT 'output_documents (manual)', COUNT(*) FILTER (WHERE auto_generated = FALSE), '6 expected' FROM output_documents
UNION ALL
SELECT 'output_documents (auto)', COUNT(*) FILTER (WHERE auto_generated = TRUE), 'varies (generated)' FROM output_documents
UNION ALL
SELECT 'legal_documents', COUNT(*), '9 expected' FROM legal_documents
UNION ALL
SELECT 'monthly_obligations_config', COUNT(*), '11 expected' FROM monthly_obligations_config;

\echo ''

-- ============================================================
-- SECTION 6: OUTPUT DOCUMENTS - NEW COLUMNS
-- ============================================================
\echo 'SECTION 6: Verifying Output Documents Structure...'
\echo ''

SELECT
    column_name,
    data_type,
    CASE WHEN is_nullable = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'output_documents'
  AND column_name IN (
      'source_input_document_ids',
      'period_year',
      'period_month',
      'obligation_status',
      'auto_generated'
  )
ORDER BY ordinal_position;

\echo ''
\echo 'Expected: 5 new columns (source_input_document_ids, period_year, period_month, obligation_status, auto_generated)'
\echo ''

-- ============================================================
-- SECTION 7: OBLIGATIONS SUMMARY
-- ============================================================
\echo 'SECTION 7: Obligations Summary (if generated)...'
\echo ''

SELECT
    COUNT(*) as total_obligations,
    COUNT(*) FILTER (WHERE obligation_status = 'pending') as pending,
    COUNT(*) FILTER (WHERE obligation_status = 'in_progress') as in_progress,
    COUNT(*) FILTER (WHERE obligation_status = 'completed') as completed,
    COUNT(*) FILTER (WHERE obligation_status = 'overdue') as overdue
FROM output_documents
WHERE auto_generated = TRUE;

\echo ''

-- ============================================================
-- SECTION 8: VIEW FUNCTIONALITY TEST
-- ============================================================
\echo 'SECTION 8: Testing Views...'
\echo ''

\echo '  v_user_profiles:'
SELECT COUNT(*) || ' users visible' as result FROM v_user_profiles;

\echo '  v_company_documents_summary:'
SELECT COUNT(*) || ' companies with document summaries' as result FROM v_company_documents_summary;

\echo '  v_obligations_dashboard:'
SELECT COUNT(*) || ' obligations in dashboard' as result FROM v_obligations_dashboard;

\echo ''

-- ============================================================
-- SECTION 9: DATABASE INFO
-- ============================================================
\echo 'SECTION 9: Database Information...'
\echo ''

SELECT
    'PostgreSQL Version' as info_type,
    version() as value
UNION ALL
SELECT
    'Current Database',
    current_database()
UNION ALL
SELECT
    'Current User',
    current_user
UNION ALL
SELECT
    'Current Timestamp',
    NOW()::TEXT;

\echo ''

-- ============================================================
-- VERIFICATION COMPLETE
-- ============================================================
\echo '========================================'
\echo 'Verification Complete!'
\echo '========================================'
\echo ''
\echo 'Next Steps:'
\echo '  1. If obligations not generated, run: \i 29_generate_2025_obligations.sql'
\echo '  2. Test views: SELECT * FROM v_obligations_dashboard;'
\echo '  3. Test functions: SELECT * FROM fn_generate_monthly_obligations(1, 2025, 12);'
\echo ''
\echo 'Database is ready for use!'
\echo '========================================'
