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
