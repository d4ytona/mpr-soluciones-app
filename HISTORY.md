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
  - Created the AI?GUIDELINES.md file explaining:
    - How the AI should interact with the project.
    - It must read HISTORY.md, README.md, and `scripts/db/` for context.
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
