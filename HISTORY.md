# HISTORY — MPR Soluciones

## 2025-11-08 — Project Initialization

- Initialized Expo project in the root folder.
- Installed dependencies: `react-dom`, `react-native-web`, Expo Router, NativeWind.
- Configured TypeScript and project structure for unified mobile + web development.

## 2025-11-09 — Application Configuration and Documentation

- **App Configuration**:

  - Converted `app.json` to `app.config.ts` for dynamic configuration:
    - Added dotenv support for sensitive keys.
    - Included placeholders for Supabase and Cloudflare R2 credentials.
    - Provided inline comments explaining the purpose of each config field.
  - Created `.env` file for environment variables (not committed to Git).

- **Project Documentation**:

  - Updated README with current project setup and technologies.
  - Updated HISTORY.md with today's changes (this entry).
  - Created the AI_GUIDELINES.md file explaining:
    - How the AI should interact with the project.
    - It must read HISTORY.md, README.md, and `scripts/database/` for context.
    - Inline comments on tables and scripts are for explanation only.
    - Responses should be in Spanish, comments in English.
    - The AI should **never execute SQL or shell commands automatically**.
    - Commits created must match exactly what is recorded in HISTORY.md.

- **Database Auditing**:

  - Designed and created `audit_log` table for recording database changes.
  - Implemented generic trigger function `fn_write_audit()` for INSERT, UPDATE, DELETE operations.
  - Created a template file for manually attaching audit triggers to tables.
  - Inline comments added for column purposes and trigger usage.
  - Tested audit functionality manually with `test_table`.

- **Users Table**:

  - Created `users` table with fields: `auth_id`, `first_name`, `last_name`, `email`, `role`, `profile_photo_url`, `phone`, `birth_date`, `id_number`, `id_type`, `created_at`, `updated_at`.
  - Inline comments included for each column to describe its purpose.
  - Attached audit trigger using `fn_write_audit()`.
  - Tested audit functionality manually with `users` table (INSERT, UPDATE, DELETE operations logged correctly).

- **Document Type Table**:

  - Created `document_types` table to standardize the classification of documents across the system, with fields: `id`, `code`, `name`, `description`, `is_active`, `created_at`, `updated_at`.
  - Added inline English comments explaining the purpose of each field.
  - Attached audit trigger using `fn_write_audit()`.
  - Tested audit functionality manually with `document_types` table (INSERT, UPDATE, DELETE operations logged correctly).

## 2025-11-10 — Core Business Tables Implementation

- **Companies Table**:
  - Created `companies` table with fields: `id`, `name`, `tax_id`, `address`, `phone`, `email`, `created_by`, `created_at`, `updated_at`, `active`, `deleted_at`.
  - Linked to `users` table via `created_by` foreign key.
  - Implemented soft delete pattern with `active` boolean and `deleted_at` timestamp.
  - Attached audit trigger using `fn_write_audit()`.
  - Populated with 3 test companies (Empresa Demo 1 C.A., Soluciones Integrales S.R.L., Rachel Graphics Studio).

- **Input Documents Table**:
  - Created `input_documents` table to store client-uploaded documents.
  - Fields: `id`, `company_id`, `document_type_id`, `title`, `file_url`, `created_at`, `updated_at`, `active`, `deleted_at`.
  - Foreign keys reference `companies` and `document_types` tables.
  - Attached audit trigger using `fn_write_audit()`.
  - Populated with 9 test documents (facturas emitidas, facturas de proveedores, recibos de nómina).

- **Output Documents Table**:
  - Created `output_documents` table for accountant-delivered documents.
  - Fields: `id`, `company_id`, `document_type_id`, `uploaded_by`, `file_url`, `notes`, `due_date`, `created_at`, `updated_at`, `active`, `deleted_at`.
  - Foreign keys reference `companies`, `document_types`, and `users` tables.
  - Attached audit trigger using `fn_write_audit()`.
  - Populated with 6 test documents (balance general, declaración ISLR).

- **Legal Documents Table**:
  - Created `legal_documents` table for company legal documentation.
  - Fields: `id`, `company_id`, `document_type_id`, `file_url`, `expiration_date`, `created_at`, `updated_at`, `active`, `deleted_at`.
  - Foreign keys reference `companies` and `document_types` tables.
  - Attached audit trigger using `fn_write_audit()`.
  - Populated with 9 test documents (RIF, cédula de identidad, registro IVSS).

- **Document Relations Table**:
  - Created `document_relations` table to link input documents with their required output documents.
  - Fields: `id`, `input_document_id`, `output_document_id`, `created_by`, `created_at`, `updated_at`, `active`, `deleted_at`.
  - Foreign keys reference `input_documents`, `output_documents`, and `users` tables.
  - Implements many-to-many relationship between input and output documents.
  - Example: "Declaración de IVA" requires "Facturas de venta" as input.
  - Attached audit trigger using `fn_write_audit()`.

- **Verification System**:
  - Created comprehensive verification script (`22_verification_script.sql`) with 13 sections:
    - Table existence, trigger verification, record counts, data integrity, foreign keys, audit log, soft delete functionality.
  - Created advanced verification script (`23_advanced_verification.sql`) for detailed debugging.
  - Created `VERIFICATION_GUIDE.md` documentation explaining how to use verification scripts.

## 2025-11-11 — Database Restructuring and Optimization

- **SQL File Renumbering**:
  - Reorganized SQL files for better organization (population scripts moved to their respective table folders):
    - `1_audit/`: 01, 02, 03
    - `2_users/`: 04, 05, 06 (06 = populate, moved from 17)
    - `3_companies/`: 06, 07, 08 (08 = populate, moved from 18)
    - `4_document_types/`: 08, 09, 10
    - `5_input_documents/`: 11, 12, 13 (13 = populate, moved from 19)
    - `6_output_documents/`: 14, 15, 16 (16 = populate, moved from 21)
    - `7_legal_documents/`: 17, 18, 19 (19 = populate, moved from 20)
    - `8_document_relations/`: 20, 21 (moved from 17, 18)
    - Root verification scripts: 22, 23
  - Updated internal file header comments to match new numbering.

- **Data Normalization**:
  - Converted all test data to lowercase for consistency:
    - User names: `rachel`, `mayerling`, `jose`
    - ID types: Changed from `'V', 'E', 'P'` to `'v', 'e', 'p'`
    - Company names: `empresa demo 1 c.a.`, `soluciones integrales s.r.l.`, `rachel graphics studio`
    - Tax IDs: `j-12345678-9`, `j-98765432-1`, `j-11223344-5`
    - Document titles and descriptions converted to lowercase
  - Updated CHECK constraint in `users` table to accept lowercase id_type values.
  - Frontend will handle text styling and formatting.

- **Database Roadmap Documentation**:
  - Created `DATABASE_ROADMAP.md` with comprehensive explanation of:
    - **Vistas (Views)**: Virtual tables for query simplification with 3 example implementations
    - **RLS Policies**: Row Level Security for multi-tenant isolation (HIGH priority)
    - **Índices**: Performance optimization with 4 types of indexes (MEDIUM-HIGH priority)
    - **Funciones Útiles**: 4 utility functions for common operations
    - **Scripts de Mantenimiento**: 5 maintenance scripts for database health
  - Included implementation priorities, time estimates, and best practices.

- **Database Verification**:
  - All tables successfully verified with test data:
    - 3 users (client, accountant, boss)
    - 3 companies (empresa demo 1, soluciones integrales, rachel graphics studio)
    - 202 document types
    - 24 documents (9 input, 6 output, 9 legal)
    - 235 audit log entries
  - PostgreSQL 17.6 running on Supabase.

## 2025-01-16 — Major Database Restructuring: Obligations System Implementation

- **Removed `document_relations` Table**:
  - Eliminated separate many-to-many relationship table.
  - Replaced with integrated approach using array fields directly in `output_documents`.
  - Deleted folder `8_document_relations/` and all related scripts.
  - Updated all documentation to reflect this change.

- **Enhanced `output_documents` Table**:
  - **NEW COLUMNS ADDED**:
    - `source_input_document_ids BIGINT[]`: Array of input document IDs (Enfoque A: direct array of IDs).
    - `period_year INTEGER`: Year of the obligation (e.g., 2025).
    - `period_month INTEGER`: Month of the obligation (1-12) with CHECK constraint.
    - `obligation_status VARCHAR(50)`: Status tracking ('pending', 'in_progress', 'completed', 'overdue') with CHECK constraint.
    - `auto_generated BOOLEAN`: Flag to distinguish auto-generated obligations from manual documents.
  - Modified `uploaded_by` to allow NULL (for auto-generated obligations).
  - Modified `file_url` to allow NULL (until document is uploaded).
  - Updated script: `6_output_documents/14_create_output_documents.sql`.

- **New Table: `monthly_obligations_config`**:
  - Configuration table for automatic obligation generation.
  - Fields: `company_id`, `document_type_id`, `frequency` ('monthly', 'quarterly', 'annual'), `due_day`, `enabled`, `notes`.
  - Includes UNIQUE constraint on `(company_id, document_type_id)` to prevent duplicates.
  - Includes 2 performance indexes for fast lookups.
  - Scripts created:
    - `8_monthly_obligations/20_create_monthly_obligations_config.sql`
    - `8_monthly_obligations/21_attach_audit_monthly_obligations_config.sql`
    - `8_monthly_obligations/22_populate_monthly_obligations_config.sql`
  - Populated with 11 test configurations across 3 companies.

- **New Functions for Obligation Management**:
  - **`fn_generate_monthly_obligations(p_company_id, p_year, p_month)`**:
    - Automatically generates obligations based on `monthly_obligations_config`.
    - Can generate for all companies (NULL) or specific company.
    - Respects frequency settings (monthly, quarterly, annual).
    - Skips existing obligations to prevent duplicates.
    - Returns summary of created/skipped obligations.
    - Script: `9_functions/22_fn_generate_monthly_obligations.sql`

  - **`fn_regenerate_obligations(p_company_id, p_year, p_month, p_force)`**:
    - Manually regenerates obligations for a specific period.
    - `p_force = TRUE`: Deletes and recreates existing auto-generated obligations.
    - `p_force = FALSE`: Only creates missing obligations.
    - Returns detailed summary of actions taken.
    - Script: `9_functions/23_fn_regenerate_obligations.sql`

- **Database Views Implementation** (6 views created):
  - **`v_user_profiles`**: Formatted user profiles with concatenated full names and formatted IDs.
  - **`v_company_documents_summary`**: Document counts per company (input, legal, output, obligations).
  - **`v_obligations_dashboard`**: Complete obligation tracking with urgency levels, days remaining, and status.
  - **`v_documents_pending_review`**: Unified view of expiring legal docs and due obligations with alert levels.
  - **`v_document_relationships`**: Shows output documents and their source input documents (unnested array).
  - **`v_document_relationships_detailed`**: Enhanced version with full input document details.
  - Scripts: `10_views/24_*.sql` through `10_views/28_*.sql`

- **Updated Seeds and Test Data**:
  - Updated `16_populate_output_documents.sql` to include new columns:
    - All manual documents marked as `auto_generated = FALSE`.
    - Period information added (year: 2024, month: 12).
    - Status set to 'completed' for delivered documents.
    - `source_input_document_ids` set to NULL initially.
  - Created obligation configuration seeds for all 3 test companies:
    - Monthly: Declaración IVA, Libro de Compras y Ventas, Retenciones IVA.
    - Quarterly: Balance General.
    - Annual: Declaración ISLR.

- **Master Execution Scripts**:
  - **`00_RUN_ALL.sql`**: Complete database setup script executing all components in order:
    - Audit system → Users → Companies → Document Types → Documents → Obligations Config → Functions → Views.
    - Includes progress indicators and summary output.
  - **`29_generate_2025_obligations.sql`**: Generates all obligations for January-November 2025:
    - Uses DO block to iterate through months.
    - Provides detailed progress notifications.
    - Includes summary queries by month and company.
  - **`30_verification_script_v2.sql`**: Updated verification script:
    - Verifies 8 tables (removed document_relations, added monthly_obligations_config).
    - Verifies 6 views.
    - Verifies 3 functions.
    - Tests new output_documents columns.
    - Provides obligation summary statistics.

- **Documentation Updates**:
  - Updated `DATABASE_ROADMAP.md`:
    - Changed status from "Fully Functional" to "Under Restructuring".
    - Updated table count (8 → 7 core + 1 config).
    - Removed references to `document_relations`.
    - Added new features section.
    - Updated truncate script to include `monthly_obligations_config`.
  - Updated `HISTORY.md` with complete implementation details (this entry).

- **Database Structure Summary**:
  - **Tables**: 8 total (7 core + 1 config + 1 audit)
    - Core: users, companies, document_types, input_documents, output_documents (enhanced), legal_documents
    - Config: monthly_obligations_config
    - System: audit_log
  - **Views**: 6 (user profiles, company summaries, obligations dashboard, pending review, relationships)
  - **Functions**: 3 (audit trigger, generate obligations, regenerate obligations)
  - **Triggers**: 7 audit triggers
  - **Document Types**: 202 cataloged
  - **Test Data**: 3 users, 3 companies, 11 obligation configs

- **Key Implementation Decisions**:
  - **Enfoque A** (Array of IDs) chosen for document relationships over JSON metadata.
  - **Manual regeneration function** included for flexibility in obligation management.
  - **Views implemented from the start** for simplified frontend development.
  - **All tables created from scratch** (no ALTER TABLE operations on existing data).
  - **Obligation generation from year start** (January 2025 onwards).

- **Next Steps**:
  1. Execute `00_RUN_ALL.sql` to recreate database with new structure.
  2. Run `29_generate_2025_obligations.sql` to populate obligations for 2025.
  3. Execute `30_verification_script_v2.sql` to verify complete setup.
  4. Test views and functions in application layer.
  5. Consider implementing RLS policies for production (Phase 1, high priority).
  6. Consider adding indexes for performance (Phase 1, high priority).
