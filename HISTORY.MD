# HISTORY.md — MPR Soluciones

## 2025-11-08 — Project Initialization

- Initialized Expo project in the root folder.
- Installed dependencies: `react-dom`, `react-native-web`, Expo Router, NativeWind.
- Configured TypeScript and project structure for unified mobile + web development.

## 2025-11-09 — Database Auditing Setup

- Converted `app.json` to `app.config.ts` for dynamic configuration:
  - Added dotenv support to load sensitive keys securely.
  - Included placeholders for Supabase and Cloudflare R2 credentials.
  - Explained purpose of each config field with inline comments.
- Set up `.env` for environment variables (not committed to Git).
- Created foundational README.
- Made initial Git commit.
- Designed and created `audit_log` table for recording changes in the database.
- Implemented `fn_write_audit()` PL/pgSQL trigger function.
- Created a template file for attaching audit triggers manually to tables.
- Tested audit functionality manually with a `test_table`:
  - INSERT, UPDATE, DELETE operations were logged correctly.
- Documented column purposes and trigger usage for clarity.
