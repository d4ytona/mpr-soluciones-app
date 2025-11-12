# Database Implementation Roadmap

This document explains the next steps for database implementation, including views, RLS policies, indexes, functions, and maintenance scripts.

---

## Current Database State

**Status:** ✅ **Fully Functional Base Implementation**

- 8 tables created (users, companies, document_types, input_documents, output_documents, legal_documents, document_relations, audit_log)
- 7 audit triggers attached and working
- 3 test users with roles (client, boss, accountant)
- 3 test companies
- 24 test documents (9 input, 9 legal, 6 output)
- 202 document types cataloged
- 235 audit entries recorded

**Last Update:** 2025-01-11
**Database Version:** PostgreSQL 17.6

---

## 1. Database Views (VISTAS)

### What are Views?

Views are virtual tables created by saved SQL queries. They don't store data themselves but provide a customized way to look at data from one or more tables.

### Purpose

- **Simplify Complex Queries:** Encapsulate complex JOINs and calculations into a simple SELECT
- **Data Abstraction:** Hide complexity from application layer
- **Security:** Show only necessary columns to specific users
- **Consistent Logic:** Ensure same business logic across all queries

### Use Cases for MPR Soluciones

#### View 1: `v_user_profiles`
Complete user information with formatted data:
```sql
CREATE VIEW v_user_profiles AS
SELECT
    u.id,
    u.auth_id,
    u.first_name || ' ' || u.last_name as full_name,
    u.email,
    u.role,
    u.id_type || '-' || u.id_number as formatted_id,
    u.profile_photo_url,
    u.active
FROM users u
WHERE u.active = TRUE;
```

**Benefits:**
- App always gets consistent formatted names
- No need to concatenate in frontend
- Easy to add calculated fields

#### View 2: `v_company_documents_summary`
Document count per company:
```sql
CREATE VIEW v_company_documents_summary AS
SELECT
    c.id,
    c.name as company_name,
    c.tax_id,
    COUNT(DISTINCT id.id) as input_docs_count,
    COUNT(DISTINCT ld.id) as legal_docs_count,
    COUNT(DISTINCT od.id) as output_docs_count
FROM companies c
LEFT JOIN input_documents id ON c.id = id.company_id AND id.active = TRUE
LEFT JOIN legal_documents ld ON c.id = ld.company_id AND ld.active = TRUE
LEFT JOIN output_documents od ON c.id = od.company_id AND od.active = TRUE
WHERE c.active = TRUE
GROUP BY c.id, c.name, c.tax_id;
```

**Benefits:**
- Dashboard can query ONE view instead of 4 tables
- Consistent counting logic
- Performance optimization

#### View 3: `v_documents_pending_review`
Documents needing attention:
```sql
CREATE VIEW v_documents_pending_review AS
SELECT
    'legal' as doc_category,
    ld.id,
    c.name as company_name,
    dt.name as document_type,
    ld.expiration_date,
    ld.expiration_date - CURRENT_DATE as days_until_expiration
FROM legal_documents ld
JOIN companies c ON ld.company_id = c.id
JOIN document_types dt ON ld.document_type_id = dt.id
WHERE ld.active = TRUE
  AND ld.expiration_date < CURRENT_DATE + INTERVAL '30 days'
UNION ALL
SELECT
    'output',
    od.id,
    c.name,
    dt.name,
    od.due_date,
    od.due_date - CURRENT_DATE
FROM output_documents od
JOIN companies c ON od.company_id = c.id
JOIN document_types dt ON od.document_type_id = dt.id
WHERE od.active = TRUE
  AND od.due_date < CURRENT_DATE + INTERVAL '7 days';
```

**Benefits:**
- Instant alert system
- Single query for notifications
- Easy to extend with more conditions

### Is it Necessary?

**Priority:** ⚠️ **MEDIUM**

- **Not required for MVP:** App can work without views
- **Highly Recommended:** Greatly simplifies frontend code
- **Performance Benefit:** Reduces network round trips
- **Best Practice:** Industry standard for data abstraction

**Recommendation:** Implement 3-5 essential views after testing basic CRUD operations.

---

## 2. Row Level Security (RLS)

### What is RLS?

Row Level Security is a PostgreSQL feature that allows you to control which rows users can see or modify based on policies you define.

### Purpose

- **Data Isolation:** Users only see their own data
- **Multi-tenancy:** Multiple companies share same tables securely
- **Role-Based Access:** Different access levels per user role
- **Security at DB Level:** Protection even if app has bugs

### Use Cases for MPR Soluciones

#### Policy 1: Users Table
Users can only see their own profile:
```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users see only themselves
CREATE POLICY users_select_own
ON users FOR SELECT
USING (auth.uid() = auth_id);

-- Policy: Admin sees all
CREATE POLICY users_select_admin
ON users FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE auth_id = auth.uid()
        AND role = 'admin'
    )
);
```

#### Policy 2: Companies Table
```sql
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

-- Clients see only their assigned company
CREATE POLICY companies_select_client
ON companies FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.auth_id = auth.uid()
        AND u.role = 'client'
        -- Add company-user relationship here
    )
);

-- Accountants see companies they manage
CREATE POLICY companies_select_accountant
ON companies FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.auth_id = auth.uid()
        AND u.role IN ('accountant', 'boss', 'admin')
    )
);
```

#### Policy 3: Documents Table (Example for input_documents)
```sql
ALTER TABLE input_documents ENABLE ROW LEVEL SECURITY;

-- Clients see documents from their company
CREATE POLICY input_documents_select_client
ON input_documents FOR SELECT
USING (
    company_id IN (
        SELECT c.id FROM companies c
        JOIN users u ON u.email = c.email  -- Simplified; needs proper relationship
        WHERE u.auth_id = auth.uid()
    )
);

-- Accountants see all documents
CREATE POLICY input_documents_select_accountant
ON input_documents FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM users u
        WHERE u.auth_id = auth.uid()
        AND u.role IN ('accountant', 'boss', 'admin')
    )
);
```

### Is it Necessary?

**Priority:** 🔴 **HIGH (Essential for Production)**

- **Required for Production:** MUST have before going live
- **Security Critical:** Prevents data leaks between companies
- **Compliance:** Required for data privacy regulations
- **Cannot Skip:** Without RLS, any user could see all data

**Recommendation:** Implement BEFORE deploying to production. Can skip for local development/testing.

---

## 3. Database Indexes

### What are Indexes?

Indexes are special database structures that improve the speed of data retrieval operations. Like an index in a book, they help the database find data faster.

### Purpose

- **Query Performance:** Speed up SELECT queries
- **Join Optimization:** Faster table joins
- **Sorting:** Faster ORDER BY operations
- **Uniqueness:** Enforce unique constraints

### Use Cases for MPR Soluciones

#### Index 1: Foreign Key Columns
```sql
-- Companies foreign key in documents
CREATE INDEX idx_input_documents_company_id
ON input_documents(company_id);

CREATE INDEX idx_legal_documents_company_id
ON legal_documents(company_id);

CREATE INDEX idx_output_documents_company_id
ON output_documents(company_id);

-- Document types foreign key
CREATE INDEX idx_input_documents_type_id
ON input_documents(document_type_id);

CREATE INDEX idx_legal_documents_type_id
ON legal_documents(document_type_id);

CREATE INDEX idx_output_documents_type_id
ON output_documents(document_type_id);
```

**Benefits:**
- Faster document lookups by company
- Faster JOIN operations
- Essential for good performance

#### Index 2: Filtering Columns
```sql
-- Active flag (commonly used in WHERE clauses)
CREATE INDEX idx_input_documents_active
ON input_documents(active)
WHERE active = TRUE;

CREATE INDEX idx_companies_active
ON companies(active)
WHERE active = TRUE;

-- Expiration dates for legal documents
CREATE INDEX idx_legal_documents_expiration
ON legal_documents(expiration_date)
WHERE expiration_date IS NOT NULL;

-- Due dates for output documents
CREATE INDEX idx_output_documents_due_date
ON output_documents(due_date)
WHERE due_date IS NOT NULL;
```

**Benefits:**
- Faster filtered queries
- Better dashboard performance
- Efficient alert queries

#### Index 3: Search Columns
```sql
-- Email lookup (for login)
CREATE INDEX idx_users_email
ON users(email);

-- Tax ID lookup
CREATE INDEX idx_companies_tax_id
ON companies(tax_id);

-- Document type lookup
CREATE INDEX idx_document_types_category
ON document_types(category_type, sub_type);
```

**Benefits:**
- Instant login lookups
- Fast company searches
- Efficient document type filtering

#### Index 4: Audit Log
```sql
-- Performance for audit queries
CREATE INDEX idx_audit_log_table_record
ON audit_log(table_name, record_id);

CREATE INDEX idx_audit_log_performed_at
ON audit_log(performed_at DESC);

CREATE INDEX idx_audit_log_performed_by
ON audit_log(performed_by);
```

**Benefits:**
- Fast audit trail lookups
- Efficient compliance reports
- Better debugging

### Is it Necessary?

**Priority:** 🟡 **MEDIUM-HIGH**

- **Not Required Initially:** App works without indexes
- **Essential for Scale:** Critical when you have 100+ companies
- **Performance Impact:** Dramatic speed improvement (10-100x faster)
- **Best Practice:** Should be added before launch

**Recommendation:** Add after initial testing, BEFORE production launch.

---

## 4. Utility Functions

### What are Database Functions?

Functions are reusable SQL code blocks that perform specific tasks. They can be called from queries or triggers.

### Purpose

- **Code Reusability:** Write once, use everywhere
- **Business Logic:** Centralize complex calculations
- **Data Validation:** Ensure data integrity
- **Automation:** Trigger-based automatic actions

### Use Cases for MPR Soluciones

#### Function 1: Auto-Update `updated_at`
```sql
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach to all tables
CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION fn_update_timestamp();

-- Repeat for all tables...
```

**Benefits:**
- Never forget to update `updated_at`
- Consistent timestamps
- Automatic tracking

#### Function 2: Soft Delete Function
```sql
CREATE OR REPLACE FUNCTION fn_soft_delete(
    p_table_name TEXT,
    p_record_id BIGINT
)
RETURNS BOOLEAN AS $$
BEGIN
    EXECUTE format(
        'UPDATE %I SET active = FALSE, deleted_at = NOW() WHERE id = $1',
        p_table_name
    ) USING p_record_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Benefits:**
- Consistent soft delete across all tables
- Single function to maintain
- Easier to add logic later

#### Function 3: Get Company Documents Count
```sql
CREATE OR REPLACE FUNCTION fn_get_company_doc_count(
    p_company_id BIGINT
)
RETURNS TABLE (
    input_count BIGINT,
    legal_count BIGINT,
    output_count BIGINT,
    total_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM input_documents WHERE company_id = p_company_id AND active = TRUE),
        (SELECT COUNT(*) FROM legal_documents WHERE company_id = p_company_id AND active = TRUE),
        (SELECT COUNT(*) FROM output_documents WHERE company_id = p_company_id AND active = TRUE),
        (SELECT COUNT(*) FROM input_documents WHERE company_id = p_company_id AND active = TRUE) +
        (SELECT COUNT(*) FROM legal_documents WHERE company_id = p_company_id AND active = TRUE) +
        (SELECT COUNT(*) FROM output_documents WHERE company_id = p_company_id AND active = TRUE);
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT * FROM fn_get_company_doc_count(1);
```

**Benefits:**
- Simple API for frontend
- Consistent counting logic
- Easy to extend

#### Function 4: Check Document Expiration
```sql
CREATE OR REPLACE FUNCTION fn_get_expiring_documents(
    p_days_ahead INTEGER DEFAULT 30
)
RETURNS TABLE (
    document_id BIGINT,
    company_name TEXT,
    document_type TEXT,
    expiration_date DATE,
    days_remaining INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ld.id,
        c.name,
        dt.name,
        ld.expiration_date,
        (ld.expiration_date - CURRENT_DATE)::INTEGER
    FROM legal_documents ld
    JOIN companies c ON ld.company_id = c.id
    JOIN document_types dt ON ld.document_type_id = dt.id
    WHERE ld.active = TRUE
      AND ld.expiration_date IS NOT NULL
      AND ld.expiration_date <= CURRENT_DATE + p_days_ahead
    ORDER BY ld.expiration_date ASC;
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT * FROM fn_get_expiring_documents(30);
```

**Benefits:**
- Easy alert system
- Configurable time window
- Reusable across app

### Is it Necessary?

**Priority:** 🟡 **MEDIUM**

- **Not Required:** App can work without custom functions
- **Quality of Life:** Makes development much easier
- **Maintainability:** Centralizes business logic
- **Best Practice:** Recommended for complex apps

**Recommendation:** Start with 2-3 essential functions, add more as needed.

---

## 5. Maintenance Scripts

### What are Maintenance Scripts?

Scripts for database administration tasks like cleanup, backup, reset, and optimization.

### Purpose

- **Database Health:** Keep database running smoothly
- **Development:** Reset to clean state
- **Testing:** Create/destroy test data
- **Troubleshooting:** Fix common issues

### Use Cases for MPR Soluciones

#### Script 1: Reset Database (Development)
```sql
-- 99_reset_database.sql
-- WARNING: This deletes ALL data

-- Disable triggers temporarily
SET session_replication_role = 'replica';

-- Truncate all tables
TRUNCATE TABLE audit_log CASCADE;
TRUNCATE TABLE document_relations CASCADE;
TRUNCATE TABLE legal_documents CASCADE;
TRUNCATE TABLE output_documents CASCADE;
TRUNCATE TABLE input_documents CASCADE;
TRUNCATE TABLE document_types CASCADE;
TRUNCATE TABLE companies CASCADE;
TRUNCATE TABLE users CASCADE;

-- Re-enable triggers
SET session_replication_role = 'origin';

-- Reset sequences
ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE companies_id_seq RESTART WITH 1;
-- ... etc for all sequences
```

**Use Case:** Quickly reset to clean state during development

#### Script 2: Clean Old Audit Logs
```sql
-- cleanup_old_audits.sql
-- Keeps only last 90 days of audit logs

DELETE FROM audit_log
WHERE performed_at < NOW() - INTERVAL '90 days';

VACUUM ANALYZE audit_log;
```

**Use Case:** Prevent audit_log from growing too large

#### Script 3: Archive Deleted Records
```sql
-- archive_soft_deleted.sql
-- Move soft-deleted records to archive tables

-- Create archive table (run once)
CREATE TABLE IF NOT EXISTS archive_companies AS
SELECT * FROM companies WHERE false;

-- Archive old deleted records
INSERT INTO archive_companies
SELECT * FROM companies
WHERE active = FALSE
  AND deleted_at < NOW() - INTERVAL '1 year';

-- Delete from main table
DELETE FROM companies
WHERE active = FALSE
  AND deleted_at < NOW() - INTERVAL '1 year';
```

**Use Case:** Keep main tables small, preserve history

#### Script 4: Database Health Check
```sql
-- health_check.sql
-- Verify database integrity

SELECT
    'Table Sizes' as check_type,
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check for missing indexes on foreign keys
SELECT
    'Missing FK Indexes' as issue,
    conrelid::regclass as table_name,
    conname as constraint_name
FROM pg_constraint
WHERE contype = 'f'
  AND NOT EXISTS (
      SELECT 1 FROM pg_index
      WHERE indexrelid = conrelid
  );

-- Check for tables without RLS
SELECT
    'Tables without RLS' as issue,
    tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename NOT IN (
      SELECT tablename FROM pg_policies
  );
```

**Use Case:** Regular maintenance checks

#### Script 5: Backup Script
```bash
#!/bin/bash
# backup_database.sh
# Creates timestamped backup

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_mpr_${TIMESTAMP}.sql"

pg_dump -h localhost -U postgres -d mpr_soluciones > $BACKUP_FILE

gzip $BACKUP_FILE

echo "Backup created: ${BACKUP_FILE}.gz"
```

**Use Case:** Regular backups before major changes

### Is it Necessary?

**Priority:** 🟢 **LOW-MEDIUM**

- **Not Urgent:** Can be added later
- **Development Aid:** Very helpful during development
- **Production Need:** Eventually required for production
- **Peace of Mind:** Good to have for emergencies

**Recommendation:** Create basic reset script now, add others as needed.

---

## Implementation Priority

Based on necessity and impact:

### Phase 1: CRITICAL (Before Production)
1. ✅ ~~Base Tables~~ (DONE)
2. ✅ ~~Audit System~~ (DONE)
3. ✅ ~~Test Data~~ (DONE)
4. 🔴 **RLS Policies** (MUST HAVE)
5. 🔴 **Basic Indexes** (MUST HAVE)

### Phase 2: IMPORTANT (Production Launch)
6. 🟡 **Essential Views** (3-5 views)
7. 🟡 **Core Functions** (2-3 functions)
8. 🟡 **Reset Script** (for development)

### Phase 3: OPTIMIZATION (Post-Launch)
9. 🟢 **Advanced Views**
10. 🟢 **Utility Functions**
11. 🟢 **Maintenance Scripts**
12. 🟢 **Performance Monitoring**

---

## Estimated Implementation Time

- **RLS Policies:** 2-3 hours
- **Indexes:** 1 hour
- **Essential Views:** 2 hours
- **Core Functions:** 2-3 hours
- **Maintenance Scripts:** 1-2 hours

**Total:** 8-11 hours for complete implementation

---

## Next Steps

1. **Read this document** to understand each component
2. **Decide priority** based on project timeline
3. **Implement RLS** as first priority (security critical)
4. **Add indexes** second (performance critical)
5. **Create views** third (developer experience)
6. **Build functions** fourth (nice to have)
7. **Write maintenance scripts** last (operational need)

---

## Document History

- **2025-01-11:** Initial roadmap created
- Database fully functional with base implementation
- Ready for next phase implementation

---
