-- ============================================================
-- VERIFICATION.sql
-- ============================================================
-- MPR Soluciones - Database Verification Script
-- Verifies that all tables, functions, views, and triggers
-- are properly created and populated.
-- ============================================================

\echo '';
\echo '========================================';
\echo 'DATABASE VERIFICATION';
\echo '========================================';
\echo '';

-- ============================================================
-- PART 1: Verify Tables
-- ============================================================
\echo '1. Verifying Tables...';
\echo '';

SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
  AND table_name IN (
    'users', 'companies', 'document_types',
    'input_documents', 'output_documents', 'legal_documents',
    'monthly_obligations_config', 'notifications',
    'output_required_inputs', 'audit_log'
  )
ORDER BY table_name;

\echo '';
\echo 'Expected: 10 tables';
\echo '';

-- ============================================================
-- PART 2: Verify Row Counts
-- ============================================================
\echo '2. Verifying Data Population...';
\echo '';

SELECT 'users' as table_name, COUNT(*) as row_count FROM users
UNION ALL
SELECT 'companies', COUNT(*) FROM companies
UNION ALL
SELECT 'document_types', COUNT(*) FROM document_types
UNION ALL
SELECT 'input_documents', COUNT(*) FROM input_documents
UNION ALL
SELECT 'output_documents', COUNT(*) FROM output_documents
UNION ALL
SELECT 'legal_documents', COUNT(*) FROM legal_documents
UNION ALL
SELECT 'monthly_obligations_config', COUNT(*) FROM monthly_obligations_config
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'output_required_inputs', COUNT(*) FROM output_required_inputs
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;

\echo '';
\echo 'Expected minimums:';
\echo '  users: 3';
\echo '  companies: 3';
\echo '  document_types: 101';
\echo '  monthly_obligations_config: 11';
\echo '';

-- ============================================================
-- PART 3: Verify Functions
-- ============================================================
\echo '3. Verifying Functions...';
\echo '';

SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'fn_write_audit',
    'fn_generate_monthly_obligations',
    'fn_regenerate_obligations',
    'fn_notify_obligation_status_change',
    'fn_notify_new_obligation'
  )
ORDER BY routine_name;

\echo '';
\echo 'Expected: 5 functions';
\echo '';

-- ============================================================
-- PART 4: Verify Triggers
-- ============================================================
\echo '4. Verifying Triggers...';
\echo '';

SELECT
    event_object_table as table_name,
    trigger_name,
    event_manipulation as event
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'trg_%'
ORDER BY event_object_table, trigger_name;

\echo '';
\echo 'Expected: 12 triggers (10 audit + 2 notification)';
\echo '';

-- ============================================================
-- PART 5: Verify Views
-- ============================================================
\echo '5. Verifying Views...';
\echo '';

SELECT
    table_name as view_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'v_%'
ORDER BY table_name;

\echo '';
\echo 'Expected: 7 views';
\echo '  v_user_profiles';
\echo '  v_company_documents_summary';
\echo '  v_obligations_dashboard';
\echo '  v_documents_pending_review';
\echo '  v_document_relationships';
\echo '  v_document_relationships_detailed';
\echo '  v_user_notifications';
\echo '';

-- ============================================================
-- PART 6: Verify Foreign Keys
-- ============================================================
\echo '6. Verifying Foreign Key Constraints...';
\echo '';

SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

\echo '';

-- ============================================================
-- PART 7: Verify Indexes
-- ============================================================
\echo '7. Verifying Indexes...';
\echo '';

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN (
    'companies', 'monthly_obligations_config',
    'notifications', 'output_required_inputs'
  )
ORDER BY tablename, indexname;

\echo '';

-- ============================================================
-- PART 8: Test Views
-- ============================================================
\echo '8. Testing View Functionality...';
\echo '';

\echo 'Testing v_obligations_dashboard...';
SELECT COUNT(*) as obligations_count FROM v_obligations_dashboard;

\echo '';
\echo 'Testing v_user_notifications...';
SELECT COUNT(*) as notifications_count FROM v_user_notifications;

\echo '';
\echo 'Testing v_company_documents_summary...';
SELECT
    company_name,
    total_docs_count,
    obligations_count
FROM v_company_documents_summary;

\echo '';

-- ============================================================
-- PART 9: Verify Document Types Distribution
-- ============================================================
\echo '9. Verifying Document Types Distribution...';
\echo '';

SELECT
    category_type,
    COUNT(*) as type_count
FROM document_types
WHERE active = TRUE
GROUP BY category_type
ORDER BY category_type;

\echo '';
\echo 'Expected:';
\echo '  legal: ~22';
\echo '  input: ~37';
\echo '  output: ~42';
\echo '  TOTAL: 101';
\echo '';

-- ============================================================
-- PART 10: Verify Companies Assignment Fields
-- ============================================================
\echo '10. Verifying Companies Assignment Fields...';
\echo '';

SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'companies'
  AND column_name IN ('assigned_to', 'assigned_accountant', 'assigned_client')
ORDER BY column_name;

\echo '';
\echo 'Expected: 3 assignment columns (all BIGINT, nullable)';
\echo '';

-- ============================================================
-- VERIFICATION COMPLETE
-- ============================================================

\echo '========================================';
\echo 'VERIFICATION COMPLETE';
\echo '========================================';
\echo '';
\echo 'Review the output above to ensure:';
\echo '  ✓ All 10 tables exist';
\echo '  ✓ All 5 functions are created';
\echo '  ✓ All 12 triggers are attached';
\echo '  ✓ All 7 views are created';
\echo '  ✓ Data is properly populated';
\echo '  ✓ Foreign keys are configured';
\echo '  ✓ Indexes are created';
\echo '';
\echo 'If any checks fail, review COMPLETE_SETUP.sql';
\echo '========================================';
