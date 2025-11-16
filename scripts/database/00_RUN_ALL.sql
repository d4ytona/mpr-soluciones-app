-- 00_RUN_ALL.sql
-- ============================================================
-- Description: Master script to execute all database scripts in order.
--              Creates entire database from scratch.
-- ============================================================
-- IMPORTANT: Run this script from the database root directory.
-- Usage: psql -d your_database < 00_RUN_ALL.sql
-- ============================================================

\echo '========================================='
\echo 'MPR Soluciones - Database Setup'
\echo 'Starting complete database creation...'
\echo '========================================='
\echo ''

-- ============================================================
-- STEP 1: AUDIT SYSTEM
-- ============================================================
\echo '1. Creating audit system...'
\i 1_audit/01_create_audit_table.sql
\i 1_audit/02_create_audit_function.sql
\echo '   ✓ Audit system created'
\echo ''

-- ============================================================
-- STEP 2: USERS TABLE
-- ============================================================
\echo '2. Creating users table...'
\i 2_users/04_create_users_table.sql
\i 2_users/05_attach_audit_users.sql
\i 2_users/06_populate_users.sql
\echo '   ✓ Users table created and populated'
\echo ''

-- ============================================================
-- STEP 3: COMPANIES TABLE
-- ============================================================
\echo '3. Creating companies table...'
\i 3_companies/06_create_companies_table.sql
\i 3_companies/07_attach_audit_companies.sql
\i 3_companies/08_populate_companies.sql
\echo '   ✓ Companies table created and populated'
\echo ''

-- ============================================================
-- STEP 4: DOCUMENT TYPES
-- ============================================================
\echo '4. Creating document types table...'
\i 4_document_types/08_create_document_types_table.sql
\i 4_document_types/09_attach_audit_document_types.sql
\i 4_document_types/10_populate_document_types.sql
\echo '   ✓ Document types created (202 types)'
\echo ''

-- ============================================================
-- STEP 5: INPUT DOCUMENTS
-- ============================================================
\echo '5. Creating input documents table...'
\i 5_input_documents/11_create_input_documents.sql
\i 5_input_documents/12_attach_audit_input_documents.sql
\i 5_input_documents/13_populate_input_documents.sql
\echo '   ✓ Input documents table created and populated'
\echo ''

-- ============================================================
-- STEP 6: OUTPUT DOCUMENTS (Enhanced)
-- ============================================================
\echo '6. Creating output documents table (enhanced)...'
\i 6_output_documents/14_create_output_documents.sql
\i 6_output_documents/15_attach_audit_output_documents.sql
\i 6_output_documents/16_populate_output_documents.sql
\echo '   ✓ Output documents table created with obligation management'
\echo ''

-- ============================================================
-- STEP 7: LEGAL DOCUMENTS
-- ============================================================
\echo '7. Creating legal documents table...'
\i 7_legal_documents/17_create_legal_documents.sql
\i 7_legal_documents/18_attach_audit_legal_documents.sql
\i 7_legal_documents/19_populate_legal_documents.sql
\echo '   ✓ Legal documents table created and populated'
\echo ''

-- ============================================================
-- STEP 8: MONTHLY OBLIGATIONS CONFIG
-- ============================================================
\echo '8. Creating monthly obligations configuration...'
\i 8_monthly_obligations/20_create_monthly_obligations_config.sql
\i 8_monthly_obligations/21_attach_audit_monthly_obligations_config.sql
\i 8_monthly_obligations/22_populate_monthly_obligations_config.sql
\echo '   ✓ Obligation configuration created'
\echo ''

-- ============================================================
-- STEP 9: UTILITY FUNCTIONS
-- ============================================================
\echo '9. Creating utility functions...'
\i 9_functions/22_fn_generate_monthly_obligations.sql
\i 9_functions/23_fn_regenerate_obligations.sql
\echo '   ✓ Utility functions created'
\echo ''

-- ============================================================
-- STEP 10: VIEWS
-- ============================================================
\echo '10. Creating database views...'
\i 10_views/24_v_user_profiles.sql
\i 10_views/25_v_company_documents_summary.sql
\i 10_views/26_v_obligations_dashboard.sql
\i 10_views/27_v_documents_pending_review.sql
\i 10_views/28_v_document_relationships.sql
\echo '   ✓ 6 views created successfully'
\echo ''

-- ============================================================
-- COMPLETE
-- ============================================================
\echo '========================================='
\echo 'Database setup complete!'
\echo '========================================='
\echo ''
\echo 'Summary:'
\echo '  - 7 core tables created'
\echo '  - 1 config table created'
\echo '  - 1 audit table created'
\echo '  - 7 audit triggers attached'
\echo '  - 202 document types loaded'
\echo '  - 2 utility functions created'
\echo '  - 6 views created'
\echo ''
\echo 'Next steps:'
\echo '  1. Generate obligations: SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, generate_series(1, 11));'
\echo '  2. Run verification: \i 22_verification_script.sql'
\echo ''
\echo 'Database ready for use!'
\echo '========================================='
