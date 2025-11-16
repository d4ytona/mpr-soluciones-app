# MPR Soluciones - Database Scripts

Complete database setup for MPR Soluciones accounting management system.

## Quick Start

### Option 1: Complete Setup (Recommended)

```bash
cd scripts/database
psql -h your-supabase-host -U postgres -d your_database -f 00_RUN_ALL.sql
```

This will:
- Create all 8 tables
- Set up 7 audit triggers
- Populate 202 document types
- Create 3 test users and companies
- Create 2 utility functions
- Create 6 database views
- Populate test data

### Option 2: Step-by-Step Setup

1. **Audit System**
   ```bash
   psql -d your_database -f 1_audit/01_create_audit_table.sql
   psql -d your_database -f 1_audit/02_create_audit_function.sql
   ```

2. **Core Tables** (in order)
   ```bash
   psql -d your_database -f 2_users/*.sql
   psql -d your_database -f 3_companies/*.sql
   psql -d your_database -f 4_document_types/*.sql
   psql -d your_database -f 5_input_documents/*.sql
   psql -d your_database -f 6_output_documents/*.sql
   psql -d your_database -f 7_legal_documents/*.sql
   psql -d your_database -f 8_monthly_obligations/*.sql
   ```

3. **Functions and Views**
   ```bash
   psql -d your_database -f 9_functions/*.sql
   psql -d your_database -f 10_views/*.sql
   ```

## Generate 2025 Obligations

After database setup, generate monthly obligations:

```bash
psql -d your_database -f 29_generate_2025_obligations.sql
```

This creates all obligations from January to November 2025 based on the configurations in `monthly_obligations_config`.

## Verification

Verify your database setup:

```bash
psql -d your_database -f 30_verification_script_v2.sql
```

This checks:
- Table existence (8 tables)
- View existence (6 views)
- Function existence (3 functions)
- Trigger attachment (7 triggers)
- Record counts
- Data integrity

## Database Structure

### Tables (8 total)

#### Core Tables (7)
1. **users** - User accounts (clients, accountants, admin)
2. **companies** - Client companies
3. **document_types** - 202 cataloged document types
4. **input_documents** - Client-uploaded documents
5. **output_documents** (Enhanced) - Accountant-delivered documents + auto-generated obligations
6. **legal_documents** - Company legal documentation
7. **monthly_obligations_config** - Configuration for automatic obligation generation

#### System Tables (1)
8. **audit_log** - Complete audit trail

### Views (6)

1. **v_user_profiles** - Formatted user data
2. **v_company_documents_summary** - Document counts per company
3. **v_obligations_dashboard** - Obligation tracking with urgency levels
4. **v_documents_pending_review** - Expiring docs and due obligations
5. **v_document_relationships** - Input → Output document relationships
6. **v_document_relationships_detailed** - Detailed relationship view

### Functions (3)

1. **fn_write_audit()** - Audit trigger function
2. **fn_generate_monthly_obligations(company_id, year, month)** - Auto-generate obligations
3. **fn_regenerate_obligations(company_id, year, month, force)** - Manually regenerate obligations

## Key Features

### Automatic Obligation Generation

The system automatically generates monthly obligations based on configuration:

```sql
-- Generate obligations for all companies for January 2025
SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, 1);

-- Generate for specific company
SELECT * FROM fn_generate_monthly_obligations(1, 2025, 2);

-- Generate for entire year
SELECT * FROM fn_generate_monthly_obligations(
    1,  -- company_id
    2025,
    generate_series(1, 12)  -- all months
);
```

### Manual Regeneration

Regenerate obligations when needed:

```sql
-- Regenerate January 2025 (skip existing)
SELECT * FROM fn_regenerate_obligations(1, 2025, 1, FALSE);

-- Force regenerate (delete and recreate)
SELECT * FROM fn_regenerate_obligations(1, 2025, 1, TRUE);
```

### Document Relationships (Enfoque A)

Output documents track their source input documents using arrays:

```sql
-- Link input documents to output document
UPDATE output_documents
SET source_input_document_ids = ARRAY[1, 2, 3, 5, 8]
WHERE id = 10;

-- View relationships
SELECT * FROM v_document_relationships_detailed
WHERE output_document_id = 10;
```

## Usage Examples

### View Pending Obligations

```sql
-- All pending obligations
SELECT * FROM v_obligations_dashboard
WHERE obligation_status = 'pending';

-- Urgent obligations (due within 7 days)
SELECT * FROM v_obligations_dashboard
WHERE urgency_level IN ('urgent', 'overdue');

-- Obligations by company
SELECT * FROM v_obligations_dashboard
WHERE company_id = 1
ORDER BY due_date;
```

### View Documents Needing Attention

```sql
-- Critical and overdue items
SELECT * FROM v_documents_pending_review
WHERE alert_level IN ('critical', 'overdue', 'expired');

-- By company
SELECT * FROM v_documents_pending_review
WHERE company_id = 1;
```

### Company Summary

```sql
-- Get complete company overview
SELECT * FROM v_company_documents_summary;

-- Companies with overdue obligations
SELECT * FROM v_company_documents_summary
WHERE overdue_obligations > 0;
```

## Test Data

The database is populated with:
- **3 users**:
  - rachel (client)
  - jose (accountant/boss)
  - mayerling (accountant)
- **3 companies**:
  - empresa demo 1 c.a. (j-12345678-9)
  - soluciones integrales s.r.l. (j-98765432-1)
  - rachel graphics studio (j-11223344-5)
- **202 document types** (legal, input, output)
- **9 input documents**
- **6 manual output documents**
- **9 legal documents**
- **11 obligation configurations**

## File Organization

```
scripts/database/
├── 00_RUN_ALL.sql                  # Master setup script
├── 1_audit/                        # Audit system
│   ├── 01_create_audit_table.sql
│   └── 02_create_audit_function.sql
├── 2_users/                        # Users table
│   ├── 04_create_users_table.sql
│   ├── 05_attach_audit_users.sql
│   └── 06_populate_users.sql
├── 3_companies/                    # Companies table
├── 4_document_types/               # Document types (202 types)
├── 5_input_documents/              # Input documents
├── 6_output_documents/             # Output documents (enhanced)
├── 7_legal_documents/              # Legal documents
├── 8_monthly_obligations/          # Obligations config
├── 9_functions/                    # Utility functions
├── 10_views/                       # Database views
├── 29_generate_2025_obligations.sql  # Generate 2025 obligations
├── 30_verification_script_v2.sql    # Verification script
└── README.md                       # This file
```

## Important Notes

1. **Database will be recreated from scratch** - All existing data will be lost when running `00_RUN_ALL.sql`
2. **Run scripts in order** - Dependencies exist between scripts
3. **Generate obligations separately** - After setup, run `29_generate_2025_obligations.sql`
4. **Auto-generated vs Manual** - `auto_generated` flag distinguishes obligation types
5. **Document relationships** - Use arrays (`source_input_document_ids`) to link documents

## Next Steps After Setup

1. ✅ Run `00_RUN_ALL.sql` to create database
2. ✅ Run `29_generate_2025_obligations.sql` to populate obligations
3. ✅ Run `30_verification_script_v2.sql` to verify
4. ⏭️ Test views and functions from your application
5. ⏭️ Implement RLS policies for production (see DATABASE_ROADMAP.md)
6. ⏭️ Add performance indexes (see DATABASE_ROADMAP.md)

## Troubleshooting

### Script fails with "relation already exists"
Run scripts with `DROP TABLE IF EXISTS` or drop database and start fresh.

### Missing functions
Ensure you ran all scripts in `9_functions/` directory.

### Views return no data
Check that:
1. Seed scripts were executed
2. Obligations were generated with `29_generate_2025_obligations.sql`
3. Data is marked as `active = TRUE`

### Permission errors
Ensure your database user has:
- CREATE TABLE privileges
- CREATE FUNCTION privileges
- CREATE TRIGGER privileges

## Support

For detailed documentation, see:
- `DATABASE_ROADMAP.md` - Future enhancements and best practices
- `HISTORY.md` - Complete change log
- `VERIFICATION_GUIDE.md` - Verification procedures (if available)

---

**Last Updated**: 2025-01-16
**Database Version**: PostgreSQL 17.6
**Status**: Production Ready (pending RLS and indexes)
