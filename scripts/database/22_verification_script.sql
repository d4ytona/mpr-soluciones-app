-- 22_verification_script.sql
-- ============================================================
-- Description: Complete verification script for database structure and test data.
--              Run this script after executing all creation and population scripts.
-- ============================================================

-- ============================================================
-- SECTION 1: TABLE EXISTENCE VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 1: TABLE EXISTENCE VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'audit_log')
        THEN '✓ audit_log table exists'
        ELSE '✗ audit_log table MISSING'
    END as table_check
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users')
        THEN '✓ users table exists'
        ELSE '✗ users table MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'companies')
        THEN '✓ companies table exists'
        ELSE '✗ companies table MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'document_types')
        THEN '✓ document_types table exists'
        ELSE '✗ document_types table MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'input_documents')
        THEN '✓ input_documents table exists'
        ELSE '✗ input_documents table MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'output_documents')
        THEN '✓ output_documents table exists'
        ELSE '✗ output_documents table MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'legal_documents')
        THEN '✓ legal_documents table exists'
        ELSE '✗ legal_documents table MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'document_relations')
        THEN '✓ document_relations table exists'
        ELSE '✗ document_relations table MISSING'
    END;

-- ============================================================
-- SECTION 2: TRIGGER EXISTENCE VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 2: TRIGGER VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            AND event_object_table = 'users'
            AND trigger_name = 'trg_audit_users'
        )
        THEN '✓ trg_audit_users trigger exists'
        ELSE '✗ trg_audit_users trigger MISSING'
    END as trigger_check
UNION ALL
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            AND event_object_table = 'companies'
            AND trigger_name = 'trg_audit_companies'
        )
        THEN '✓ trg_audit_companies trigger exists'
        ELSE '✗ trg_audit_companies trigger MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            AND event_object_table = 'document_types'
            AND trigger_name = 'trg_audit_document_types'
        )
        THEN '✓ trg_audit_document_types trigger exists'
        ELSE '✗ trg_audit_document_types trigger MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            AND event_object_table = 'input_documents'
            AND trigger_name = 'trg_audit_input_documents'
        )
        THEN '✓ trg_audit_input_documents trigger exists'
        ELSE '✗ trg_audit_input_documents trigger MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            AND event_object_table = 'output_documents'
            AND trigger_name = 'trg_audit_output_documents'
        )
        THEN '✓ trg_audit_output_documents trigger exists'
        ELSE '✗ trg_audit_output_documents trigger MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            AND event_object_table = 'legal_documents'
            AND trigger_name = 'trg_audit_legal_documents'
        )
        THEN '✓ trg_audit_legal_documents trigger exists'
        ELSE '✗ trg_audit_legal_documents trigger MISSING'
    END
UNION ALL
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.triggers
            WHERE trigger_schema = 'public'
            AND event_object_table = 'document_relations'
            AND trigger_name = 'trg_audit_document_relations'
        )
        THEN '✓ trg_audit_document_relations trigger exists'
        ELSE '✗ trg_audit_document_relations trigger MISSING'
    END;

-- ============================================================
-- SECTION 3: DATA COUNT VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 3: DATA COUNT VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    'users' as table_name,
    COUNT(*) as record_count,
    3 as expected_count,
    CASE
        WHEN COUNT(*) = 3 THEN '✓ PASS'
        ELSE '✗ FAIL'
    END as status
FROM public.users
UNION ALL
SELECT
    'companies',
    COUNT(*),
    3,
    CASE WHEN COUNT(*) = 3 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.companies
UNION ALL
SELECT
    'document_types',
    COUNT(*),
    148,
    CASE WHEN COUNT(*) >= 140 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.document_types
UNION ALL
SELECT
    'input_documents',
    COUNT(*),
    9,
    CASE WHEN COUNT(*) = 9 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.input_documents
UNION ALL
SELECT
    'legal_documents',
    COUNT(*),
    9,
    CASE WHEN COUNT(*) = 9 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.legal_documents
UNION ALL
SELECT
    'output_documents',
    COUNT(*),
    6,
    CASE WHEN COUNT(*) = 6 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.output_documents
UNION ALL
SELECT
    'audit_log',
    COUNT(*),
    0,
    CASE WHEN COUNT(*) > 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.audit_log
UNION ALL
SELECT
    'document_relations',
    COUNT(*),
    0,
    CASE WHEN COUNT(*) >= 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.document_relations;

-- ============================================================
-- SECTION 4: USER DATA VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 4: USER DATA VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    id,
    auth_id,
    first_name || ' ' || last_name as full_name,
    email,
    role,
    CASE
        WHEN profile_photo_url IS NOT NULL THEN '✓ Has photo'
        ELSE '✗ No photo'
    END as photo_status,
    active
FROM public.users
ORDER BY role, email;

-- ============================================================
-- SECTION 5: COMPANY DATA VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 5: COMPANY DATA VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    id,
    name,
    tax_id,
    created_by,
    (SELECT first_name || ' ' || last_name FROM public.users WHERE id = companies.created_by) as created_by_name,
    active
FROM public.companies
ORDER BY name;

-- ============================================================
-- SECTION 6: DOCUMENT TYPES BREAKDOWN
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 6: DOCUMENT TYPES BREAKDOWN';
    RAISE NOTICE '========================================';
END $$;

SELECT
    category_type,
    COUNT(*) as type_count,
    CASE
        WHEN category_type = 'input' THEN 'Expected: ~60'
        WHEN category_type = 'legal' THEN 'Expected: ~40'
        WHEN category_type = 'output' THEN 'Expected: ~48'
    END as expected_range
FROM public.document_types
WHERE active = TRUE
GROUP BY category_type
ORDER BY category_type;

-- ============================================================
-- SECTION 7: INPUT DOCUMENTS VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 7: INPUT DOCUMENTS VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    c.name as company_name,
    dt.name as document_type,
    id.title,
    CASE
        WHEN id.file_url LIKE '%mprsoluciones.com%' THEN '✓ Valid URL'
        ELSE '✗ Invalid URL'
    END as url_check,
    id.active
FROM public.input_documents id
JOIN public.companies c ON id.company_id = c.id
JOIN public.document_types dt ON id.document_type_id = dt.id
ORDER BY c.name, dt.name;

-- ============================================================
-- SECTION 8: LEGAL DOCUMENTS VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 8: LEGAL DOCUMENTS VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    c.name as company_name,
    dt.name as document_type,
    ld.expiration_date,
    CASE
        WHEN ld.file_url LIKE '%mprsoluciones.com%' THEN '✓ Valid URL'
        ELSE '✗ Invalid URL'
    END as url_check,
    CASE
        WHEN ld.expiration_date IS NOT NULL AND ld.expiration_date < CURRENT_DATE THEN '⚠ EXPIRED'
        WHEN ld.expiration_date IS NOT NULL AND ld.expiration_date < CURRENT_DATE + INTERVAL '30 days' THEN '⚠ Expiring soon'
        ELSE '✓ Valid'
    END as expiration_status,
    ld.active
FROM public.legal_documents ld
JOIN public.companies c ON ld.company_id = c.id
JOIN public.document_types dt ON ld.document_type_id = dt.id
ORDER BY c.name, dt.name;

-- ============================================================
-- SECTION 9: OUTPUT DOCUMENTS VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 9: OUTPUT DOCUMENTS VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    c.name as company_name,
    dt.name as document_type,
    u.first_name || ' ' || u.last_name as uploaded_by_name,
    od.due_date,
    CASE
        WHEN od.file_url LIKE '%mprsoluciones.com%' THEN '✓ Valid URL'
        ELSE '✗ Invalid URL'
    END as url_check,
    CASE
        WHEN od.due_date IS NOT NULL AND od.due_date < CURRENT_DATE THEN '⚠ OVERDUE'
        WHEN od.due_date IS NOT NULL AND od.due_date < CURRENT_DATE + INTERVAL '7 days' THEN '⚠ Due soon'
        ELSE '✓ On time'
    END as due_status,
    od.active
FROM public.output_documents od
JOIN public.companies c ON od.company_id = c.id
JOIN public.document_types dt ON od.document_type_id = dt.id
JOIN public.users u ON od.uploaded_by = u.id
ORDER BY c.name, dt.name;

-- ============================================================
-- SECTION 10: FOREIGN KEY VALIDATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 10: FOREIGN KEY VALIDATION';
    RAISE NOTICE '========================================';
END $$;

-- Check for orphaned input_documents
SELECT
    'input_documents orphans' as check_type,
    COUNT(*) as orphan_count,
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END as status
FROM public.input_documents id
WHERE NOT EXISTS (SELECT 1 FROM public.companies WHERE id = id.company_id)
   OR NOT EXISTS (SELECT 1 FROM public.document_types WHERE id = id.document_type_id)
UNION ALL
-- Check for orphaned legal_documents
SELECT
    'legal_documents orphans',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.legal_documents ld
WHERE NOT EXISTS (SELECT 1 FROM public.companies WHERE id = ld.company_id)
   OR NOT EXISTS (SELECT 1 FROM public.document_types WHERE id = ld.document_type_id)
UNION ALL
-- Check for orphaned output_documents
SELECT
    'output_documents orphans',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ PASS' ELSE '✗ FAIL' END
FROM public.output_documents od
WHERE NOT EXISTS (SELECT 1 FROM public.companies WHERE id = od.company_id)
   OR NOT EXISTS (SELECT 1 FROM public.document_types WHERE id = od.document_type_id)
   OR NOT EXISTS (SELECT 1 FROM public.users WHERE id = od.uploaded_by);

-- ============================================================
-- SECTION 11: AUDIT LOG VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 11: AUDIT LOG VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    table_name,
    operation,
    COUNT(*) as operation_count
FROM public.audit_log
GROUP BY table_name, operation
ORDER BY table_name, operation;

-- ============================================================
-- SECTION 12: SOFT DELETE VERIFICATION
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 12: SOFT DELETE VERIFICATION';
    RAISE NOTICE '========================================';
END $$;

SELECT
    'users' as table_name,
    COUNT(*) FILTER (WHERE active = TRUE) as active_count,
    COUNT(*) FILTER (WHERE active = FALSE) as deleted_count,
    COUNT(*) as total_count
FROM public.users
UNION ALL
SELECT
    'companies',
    COUNT(*) FILTER (WHERE active = TRUE),
    COUNT(*) FILTER (WHERE active = FALSE),
    COUNT(*)
FROM public.companies
UNION ALL
SELECT
    'document_types',
    COUNT(*) FILTER (WHERE active = TRUE),
    COUNT(*) FILTER (WHERE active = FALSE),
    COUNT(*)
FROM public.document_types
UNION ALL
SELECT
    'input_documents',
    COUNT(*) FILTER (WHERE active = TRUE),
    COUNT(*) FILTER (WHERE active = FALSE),
    COUNT(*)
FROM public.input_documents
UNION ALL
SELECT
    'legal_documents',
    COUNT(*) FILTER (WHERE active = TRUE),
    COUNT(*) FILTER (WHERE active = FALSE),
    COUNT(*)
FROM public.legal_documents
UNION ALL
SELECT
    'output_documents',
    COUNT(*) FILTER (WHERE active = TRUE),
    COUNT(*) FILTER (WHERE active = FALSE),
    COUNT(*)
FROM public.output_documents
UNION ALL
SELECT
    'document_relations',
    COUNT(*) FILTER (WHERE active = TRUE),
    COUNT(*) FILTER (WHERE active = FALSE),
    COUNT(*)
FROM public.document_relations;

-- ============================================================
-- SECTION 13: SUMMARY REPORT
-- ============================================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SECTION 13: SUMMARY REPORT';
    RAISE NOTICE '========================================';
END $$;

SELECT
    'Total Users' as metric,
    COUNT(*)::TEXT as value
FROM public.users
UNION ALL
SELECT
    'Total Companies',
    COUNT(*)::TEXT
FROM public.companies
UNION ALL
SELECT
    'Total Document Types',
    COUNT(*)::TEXT
FROM public.document_types
UNION ALL
SELECT
    'Total Documents (All Types)',
    (
        (SELECT COUNT(*) FROM public.input_documents) +
        (SELECT COUNT(*) FROM public.legal_documents) +
        (SELECT COUNT(*) FROM public.output_documents)
    )::TEXT
UNION ALL
SELECT
    'Total Audit Entries',
    COUNT(*)::TEXT
FROM public.audit_log
UNION ALL
SELECT
    'Database Version',
    version()::TEXT;

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'VERIFICATION COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
END $$;
