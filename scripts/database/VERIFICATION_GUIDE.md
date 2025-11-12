# Database Verification Guide

This guide explains how to use the verification scripts to validate your database setup and test data.

---

## Available Verification Scripts

### 1. **22_verification_script.sql** (Basic Verification)
Complete automated verification script that checks all critical aspects of the database.

### 2. **23_advanced_verification.sql** (Advanced Analysis)
Detailed queries for deep inspection and debugging.

---

## How to Use the Basic Verification Script

### Step 1: Execute the Script

In Supabase SQL Editor:

1. Open **SQL Editor**
2. Create a new query
3. Copy the contents of `22_verification_script.sql`
4. Click **Run**

### Step 2: Review the Output

The script produces **13 sections** of verification results:

#### Section 1: Table Existence Verification
```
✓ audit_log table exists
✓ users table exists
✓ companies table exists
✓ document_types table exists
✓ input_documents table exists
✓ output_documents table exists
✓ legal_documents table exists
```

**What to look for:** All tables should show ✓ checkmarks.

---

#### Section 2: Trigger Verification
```
✓ trg_audit_users trigger exists
✓ trg_audit_companies trigger exists
✓ trg_audit_document_types trigger exists
✓ trg_audit_input_documents trigger exists
✓ trg_audit_output_documents trigger exists
✓ trg_audit_legal_documents trigger exists
```

**What to look for:** All triggers should show ✓ checkmarks.

---

#### Section 3: Data Count Verification
```
table_name        | record_count | expected_count | status
------------------|--------------|----------------|--------
users             | 3            | 3              | ✓ PASS
companies         | 3            | 3              | ✓ PASS
document_types    | 148          | 148            | ✓ PASS
input_documents   | 9            | 9              | ✓ PASS
legal_documents   | 9            | 9              | ✓ PASS
output_documents  | 6            | 6              | ✓ PASS
audit_log         | 27           | 0              | ✓ PASS
```

**What to look for:**
- All status should be ✓ PASS
- `audit_log` should have records (shows triggers are working)

---

#### Section 4: User Data Verification
```
id | auth_id                              | full_name           | email                                 | role       | photo_status | active
---|--------------------------------------|---------------------|---------------------------------------|------------|--------------|--------
2  | ab81d562-066a-4c73-96cd-79d8b9215e7b | Mayerling Rodriguez | mayerling.rodriguez@mprsoluciones.com | boss       | ✓ Has photo  | t
3  | d9003b2b-571b-4bbf-b75d-2557b3e8d08c | Jose Layett         | joselayett@gmail.com                  | accountant | ✓ Has photo  | t
1  | 949d2686-1940-4e48-b27b-a8f90abf11d8 | Rachel Solano       | rachelgraphicss@gmail.com             | client     | ✗ No photo   | t
```

**What to look for:**
- 3 users total
- Boss and accountant should have photos
- All should be active (t = true)

---

#### Section 5: Company Data Verification
```
id | name                        | tax_id        | created_by | created_by_name     | active
---|----------------------------|---------------|------------|---------------------|--------
1  | Empresa Demo 1 C.A.        | J-12345678-9  | 2          | Mayerling Rodriguez | t
2  | Rachel Graphics Studio     | J-11223344-5  | 2          | Mayerling Rodriguez | t
3  | Soluciones Integrales S.R.L | J-98765432-1 | 3          | Jose Layett         | t
```

**What to look for:**
- 3 companies total
- All should have valid creators
- All should be active

---

#### Section 6: Document Types Breakdown
```
category_type | type_count | expected_range
--------------|------------|----------------
input         | 60         | Expected: ~60
legal         | 40         | Expected: ~40
output        | 48         | Expected: ~48
```

**What to look for:**
- Counts should match or be close to expected ranges

---

#### Section 7-9: Document Verification

These sections show all documents with URL validation:

```
company_name                  | document_type              | url_check    | active
-----------------------------|----------------------------|--------------|--------
Empresa Demo 1 C.A.          | facturas emitidas          | ✓ Valid URL  | t
Soluciones Integrales S.R.L. | facturas de proveedores    | ✓ Valid URL  | t
Rachel Graphics Studio       | recibos de pago de nomina  | ✓ Valid URL  | t
```

**What to look for:**
- All URLs should show ✓ Valid URL
- All documents should be active

---

#### Section 10: Foreign Key Validation
```
check_type                  | orphan_count | status
----------------------------|--------------|--------
input_documents orphans     | 0            | ✓ PASS
legal_documents orphans     | 0            | ✓ PASS
output_documents orphans    | 0            | ✓ PASS
```

**What to look for:**
- All should have 0 orphans
- All should show ✓ PASS

---

#### Section 11: Audit Log Verification
```
table_name        | operation | operation_count
------------------|-----------|----------------
companies         | INSERT    | 3
document_types    | INSERT    | 148
input_documents   | INSERT    | 9
legal_documents   | INSERT    | 9
output_documents  | INSERT    | 6
users             | INSERT    | 3
```

**What to look for:**
- Should match your insert counts
- Confirms triggers are working

---

#### Section 12: Soft Delete Verification
```
table_name        | active_count | deleted_count | total_count
------------------|--------------|---------------|-------------
users             | 3            | 0             | 3
companies         | 3            | 0             | 3
document_types    | 148          | 0             | 148
input_documents   | 9            | 0             | 9
legal_documents   | 9            | 0             | 9
output_documents  | 6            | 0             | 6
```

**What to look for:**
- All deleted_count should be 0 (fresh install)
- active_count should match total_count

---

#### Section 13: Summary Report
```
metric                         | value
-------------------------------|-------
Total Users                    | 3
Total Companies                | 3
Total Document Types           | 148
Total Documents (All Types)    | 24
Total Audit Entries            | 178
Database Version               | PostgreSQL 15.x
```

**What to look for:**
- Total Documents should be 24 (9+9+6)
- Audit entries should be > 0

---

## How to Use the Advanced Verification Script

The advanced script provides **13 detailed queries** for deeper analysis:

### Running Individual Queries

You can run specific queries from `23_advanced_verification.sql`:

1. Copy the specific query section you need
2. Paste into SQL Editor
3. Execute

### Key Advanced Queries

#### Query 4: Documents Per Company
Shows document distribution across companies:
```sql
SELECT
    c.name as company_name,
    c.tax_id,
    (SELECT COUNT(*) FROM public.input_documents WHERE company_id = c.id) as input_docs,
    (SELECT COUNT(*) FROM public.legal_documents WHERE company_id = c.id) as legal_docs,
    (SELECT COUNT(*) FROM public.output_documents WHERE company_id = c.id) as output_docs
FROM public.companies c;
```

Expected result: Each company should have 3 input, 3 legal, and 2 output documents.

---

#### Query 6: Legal Documents with Expiration Tracking
Shows which documents are expired or expiring soon:
```sql
SELECT
    c.name as company_name,
    dt.name as document_type,
    ld.expiration_date,
    CASE
        WHEN ld.expiration_date IS NULL THEN 'No expiration'
        WHEN ld.expiration_date < CURRENT_DATE THEN 'EXPIRED'
        WHEN ld.expiration_date < CURRENT_DATE + INTERVAL '30 days' THEN 'Expiring in <30 days'
        ELSE 'Valid'
    END as expiration_status
FROM public.legal_documents ld
JOIN public.companies c ON ld.company_id = c.id
JOIN public.document_types dt ON ld.document_type_id = dt.id;
```

---

#### Query 10: Data Integrity Check
Checks for common data quality issues:
```sql
-- Check for users without auth_id
SELECT COUNT(*) FROM public.users WHERE auth_id IS NULL;

-- Check for documents without file_url
SELECT COUNT(*) FROM public.input_documents WHERE file_url IS NULL;
```

All counts should be 0.

---

## Common Issues and Solutions

### Issue 1: Missing Tables
**Symptom:** `✗ table MISSING` in Section 1

**Solution:**
1. Review execution order of creation scripts
2. Ensure all `XX_create_*.sql` scripts were executed
3. Check for errors in SQL Editor history

---

### Issue 2: Missing Triggers
**Symptom:** `✗ trigger MISSING` in Section 2

**Solution:**
1. Execute the corresponding `XX_attach_audit_*.sql` script
2. Verify `fn_write_audit()` function exists
3. Run: `SELECT * FROM pg_proc WHERE proname = 'fn_write_audit';`

---

### Issue 3: Wrong Record Counts
**Symptom:** `✗ FAIL` in Section 3

**Solution:**
1. Check if population scripts were executed
2. Verify no manual deletions occurred
3. Re-run the corresponding `XX_populate_*.sql` script

---

### Issue 4: No Audit Entries
**Symptom:** `audit_log` count = 0

**Solution:**
1. Triggers are not attached
2. Execute all `XX_attach_audit_*.sql` scripts
3. Test by inserting a dummy record

---

### Issue 5: Invalid URLs
**Symptom:** `✗ Invalid URL` in Sections 7-9

**Solution:**
1. Check if URLs use correct domain
2. Verify URL encoding (spaces should be %20)
3. Re-run population scripts with corrected URLs

---

### Issue 6: Foreign Key Orphans
**Symptom:** `✗ FAIL` in Section 10

**Solution:**
1. This indicates data integrity violation
2. Re-run population scripts in correct order:
   - Users first
   - Companies second
   - Document types third
   - Documents last

---

## Quick Health Check

Run this single query for a quick health check:

```sql
SELECT
    'Tables' as component,
    COUNT(*) as count,
    7 as expected,
    CASE WHEN COUNT(*) = 7 THEN '✓' ELSE '✗' END as status
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
UNION ALL
SELECT
    'Users',
    COUNT(*),
    3,
    CASE WHEN COUNT(*) = 3 THEN '✓' ELSE '✗' END
FROM public.users
UNION ALL
SELECT
    'Companies',
    COUNT(*),
    3,
    CASE WHEN COUNT(*) = 3 THEN '✓' ELSE '✗' END
FROM public.companies
UNION ALL
SELECT
    'Documents',
    COUNT(*),
    24,
    CASE WHEN COUNT(*) = 24 THEN '✓' ELSE '✗' END
FROM (
    SELECT id FROM public.input_documents
    UNION ALL
    SELECT id FROM public.legal_documents
    UNION ALL
    SELECT id FROM public.output_documents
) all_docs;
```

All status should show ✓.

---

## Next Steps After Verification

Once all verifications pass:

1. ✅ **Enable RLS (Row Level Security)**
2. ✅ **Create RLS policies for each table**
3. ✅ **Set up Supabase Storage buckets**
4. ✅ **Configure authentication policies**
5. ✅ **Test API endpoints**
6. ✅ **Begin frontend integration**

---

## Support

If you encounter issues not covered in this guide:

1. Check `HISTORY.md` for project context
2. Review `DATABASE_INFO.md` for structure details
3. Examine error messages in Supabase SQL Editor
4. Verify execution order of all scripts
