-- 23_advanced_verification.sql
-- ============================================================
-- Description: Advanced verification queries for debugging and detailed analysis.
--              Use this script for deeper inspection of database state.
-- ============================================================

-- ============================================================
-- QUERY 1: Show all users with complete details
-- ============================================================
SELECT
    '=== USERS DETAILED VIEW ===' as section;

SELECT
    u.id,
    u.auth_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone,
    u.birth_date,
    u.id_type,
    u.id_number,
    u.role,
    u.profile_photo_url,
    u.created_at,
    u.updated_at,
    u.active,
    u.deleted_at
FROM public.users u
ORDER BY u.role, u.email;

-- ============================================================
-- QUERY 2: Show all companies with creator information
-- ============================================================
SELECT
    '=== COMPANIES DETAILED VIEW ===' as section;

SELECT
    c.id,
    c.name,
    c.tax_id,
    c.address,
    c.phone,
    c.email,
    c.created_by,
    u.first_name || ' ' || u.last_name as created_by_name,
    u.role as creator_role,
    c.created_at,
    c.updated_at,
    c.active,
    c.deleted_at
FROM public.companies c
LEFT JOIN public.users u ON c.created_by = u.id
ORDER BY c.name;

-- ============================================================
-- QUERY 3: Document types grouped by category and subtype
-- ============================================================
SELECT
    '=== DOCUMENT TYPES BY CATEGORY ===' as section;

SELECT
    category_type,
    sub_type,
    COUNT(*) as type_count,
    STRING_AGG(name, ', ' ORDER BY name) as document_names
FROM public.document_types
WHERE active = TRUE
GROUP BY category_type, sub_type
ORDER BY category_type, sub_type;

-- ============================================================
-- QUERY 4: Complete document overview per company
-- ============================================================
SELECT
    '=== DOCUMENTS PER COMPANY ===' as section;

SELECT
    c.name as company_name,
    c.tax_id,
    (SELECT COUNT(*) FROM public.input_documents WHERE company_id = c.id AND active = TRUE) as input_docs,
    (SELECT COUNT(*) FROM public.legal_documents WHERE company_id = c.id AND active = TRUE) as legal_docs,
    (SELECT COUNT(*) FROM public.output_documents WHERE company_id = c.id AND active = TRUE) as output_docs,
    (
        (SELECT COUNT(*) FROM public.input_documents WHERE company_id = c.id AND active = TRUE) +
        (SELECT COUNT(*) FROM public.legal_documents WHERE company_id = c.id AND active = TRUE) +
        (SELECT COUNT(*) FROM public.output_documents WHERE company_id = c.id AND active = TRUE)
    ) as total_docs
FROM public.companies c
WHERE c.active = TRUE
ORDER BY c.name;

-- ============================================================
-- QUERY 5: All input documents with full details
-- ============================================================
SELECT
    '=== INPUT DOCUMENTS DETAILED ===' as section;

SELECT
    id.id,
    c.name as company_name,
    c.tax_id,
    dt.category_type,
    dt.sub_type,
    dt.name as document_type,
    id.title,
    id.file_url,
    id.created_at,
    id.active
FROM public.input_documents id
JOIN public.companies c ON id.company_id = c.id
JOIN public.document_types dt ON id.document_type_id = dt.id
ORDER BY c.name, dt.sub_type, dt.name;

-- ============================================================
-- QUERY 6: All legal documents with expiration tracking
-- ============================================================
SELECT
    '=== LEGAL DOCUMENTS WITH EXPIRATION ===' as section;

SELECT
    ld.id,
    c.name as company_name,
    c.tax_id,
    dt.sub_type,
    dt.name as document_type,
    ld.file_url,
    ld.expiration_date,
    CASE
        WHEN ld.expiration_date IS NULL THEN 'No expiration'
        WHEN ld.expiration_date < CURRENT_DATE THEN 'EXPIRED'
        WHEN ld.expiration_date < CURRENT_DATE + INTERVAL '30 days' THEN 'Expiring in <30 days'
        WHEN ld.expiration_date < CURRENT_DATE + INTERVAL '90 days' THEN 'Expiring in <90 days'
        ELSE 'Valid'
    END as expiration_status,
    CASE
        WHEN ld.expiration_date IS NOT NULL THEN
            ld.expiration_date - CURRENT_DATE
        ELSE NULL
    END as days_until_expiration,
    ld.created_at,
    ld.active
FROM public.legal_documents ld
JOIN public.companies c ON ld.company_id = c.id
JOIN public.document_types dt ON ld.document_type_id = dt.id
ORDER BY
    CASE
        WHEN ld.expiration_date IS NULL THEN 3
        WHEN ld.expiration_date < CURRENT_DATE THEN 0
        ELSE 1
    END,
    ld.expiration_date NULLS LAST,
    c.name;

-- ============================================================
-- QUERY 7: All output documents with accountant info
-- ============================================================
SELECT
    '=== OUTPUT DOCUMENTS DETAILED ===' as section;

SELECT
    od.id,
    c.name as company_name,
    c.tax_id,
    dt.sub_type,
    dt.name as document_type,
    u.first_name || ' ' || u.last_name as uploaded_by,
    u.role as uploader_role,
    od.file_url,
    od.notes,
    od.due_date,
    CASE
        WHEN od.due_date IS NULL THEN 'No due date'
        WHEN od.due_date < CURRENT_DATE THEN 'OVERDUE'
        WHEN od.due_date < CURRENT_DATE + INTERVAL '7 days' THEN 'Due this week'
        WHEN od.due_date < CURRENT_DATE + INTERVAL '30 days' THEN 'Due this month'
        ELSE 'On schedule'
    END as due_status,
    od.created_at,
    od.active
FROM public.output_documents od
JOIN public.companies c ON od.company_id = c.id
JOIN public.document_types dt ON od.document_type_id = dt.id
JOIN public.users u ON od.uploaded_by = u.id
ORDER BY
    CASE
        WHEN od.due_date IS NULL THEN 3
        WHEN od.due_date < CURRENT_DATE THEN 0
        ELSE 1
    END,
    od.due_date NULLS LAST,
    c.name;

-- ============================================================
-- QUERY 8: Audit log analysis
-- ============================================================
SELECT
    '=== AUDIT LOG ANALYSIS ===' as section;

SELECT
    al.table_name,
    al.operation,
    COUNT(*) as total_operations,
    MIN(al.performed_at) as first_operation,
    MAX(al.performed_at) as last_operation,
    COUNT(DISTINCT al.performed_by) as unique_users
FROM public.audit_log al
GROUP BY al.table_name, al.operation
ORDER BY al.table_name, al.operation;

-- ============================================================
-- QUERY 9: Recent audit entries (last 20)
-- ============================================================
SELECT
    '=== RECENT AUDIT ENTRIES ===' as section;

SELECT
    al.id,
    al.table_name,
    al.record_id,
    al.operation,
    u.first_name || ' ' || u.last_name as performed_by_name,
    al.performed_at,
    al.old_data,
    al.new_data
FROM public.audit_log al
LEFT JOIN public.users u ON al.performed_by = u.auth_id
ORDER BY al.performed_at DESC
LIMIT 20;

-- ============================================================
-- QUERY 10: Check for data integrity issues
-- ============================================================
SELECT
    '=== DATA INTEGRITY CHECK ===' as section;

-- Users without auth_id
SELECT
    'Users without auth_id' as issue,
    COUNT(*) as count,
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ ISSUE FOUND' END as status
FROM public.users
WHERE auth_id IS NULL
UNION ALL
-- Companies without name or tax_id
SELECT
    'Companies without name/tax_id',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ ISSUE FOUND' END
FROM public.companies
WHERE name IS NULL OR tax_id IS NULL
UNION ALL
-- Documents without file_url
SELECT
    'Input docs without file_url',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ ISSUE FOUND' END
FROM public.input_documents
WHERE file_url IS NULL OR file_url = ''
UNION ALL
SELECT
    'Legal docs without file_url',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ ISSUE FOUND' END
FROM public.legal_documents
WHERE file_url IS NULL OR file_url = ''
UNION ALL
SELECT
    'Output docs without file_url',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ ISSUE FOUND' END
FROM public.output_documents
WHERE file_url IS NULL OR file_url = ''
UNION ALL
-- Documents with invalid URLs
SELECT
    'Docs with invalid URLs',
    (
        (SELECT COUNT(*) FROM public.input_documents WHERE file_url NOT LIKE 'http%') +
        (SELECT COUNT(*) FROM public.legal_documents WHERE file_url NOT LIKE 'http%') +
        (SELECT COUNT(*) FROM public.output_documents WHERE file_url NOT LIKE 'http%')
    ),
    CASE WHEN (
        (SELECT COUNT(*) FROM public.input_documents WHERE file_url NOT LIKE 'http%') +
        (SELECT COUNT(*) FROM public.legal_documents WHERE file_url NOT LIKE 'http%') +
        (SELECT COUNT(*) FROM public.output_documents WHERE file_url NOT LIKE 'http%')
    ) = 0 THEN '✓ OK' ELSE '✗ ISSUE FOUND' END;

-- ============================================================
-- QUERY 11: Table size and row count statistics
-- ============================================================
SELECT
    '=== TABLE STATISTICS ===' as section;

SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ============================================================
-- QUERY 12: Missing or duplicate data check
-- ============================================================
SELECT
    '=== DUPLICATE CHECK ===' as section;

-- Check for duplicate tax_ids in companies
SELECT
    'Duplicate tax_ids' as issue,
    tax_id,
    COUNT(*) as duplicate_count
FROM public.companies
GROUP BY tax_id
HAVING COUNT(*) > 1
UNION ALL
-- Check for duplicate auth_ids in users
SELECT
    'Duplicate auth_ids',
    auth_id::TEXT,
    COUNT(*)
FROM public.users
GROUP BY auth_id
HAVING COUNT(*) > 1;

-- ============================================================
-- QUERY 13: Document URL validation
-- ============================================================
SELECT
    '=== DOCUMENT URL VALIDATION ===' as section;

SELECT
    'Input Documents' as doc_category,
    COUNT(*) as total_docs,
    COUNT(*) FILTER (WHERE file_url LIKE '%mprsoluciones.com%') as valid_urls,
    COUNT(*) FILTER (WHERE file_url NOT LIKE '%mprsoluciones.com%') as invalid_urls
FROM public.input_documents
UNION ALL
SELECT
    'Legal Documents',
    COUNT(*),
    COUNT(*) FILTER (WHERE file_url LIKE '%mprsoluciones.com%'),
    COUNT(*) FILTER (WHERE file_url NOT LIKE '%mprsoluciones.com%')
FROM public.legal_documents
UNION ALL
SELECT
    'Output Documents',
    COUNT(*),
    COUNT(*) FILTER (WHERE file_url LIKE '%mprsoluciones.com%'),
    COUNT(*) FILTER (WHERE file_url NOT LIKE '%mprsoluciones.com%')
FROM public.output_documents;

-- ============================================================
-- END OF ADVANCED VERIFICATION
-- ============================================================
SELECT
    '=== ADVANCED VERIFICATION COMPLETE ===' as section;
