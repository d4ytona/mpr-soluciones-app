-- 01_create_audit_table.sql
-- ============================================================
-- Description: Creates a generic audit log table for tracking
--              INSERT, UPDATE, and DELETE operations on tables.
-- ============================================================
DROP TABLE IF EXISTS public.audit_log;

CREATE TABLE IF NOT EXISTS public.audit_log (
    id BIGSERIAL PRIMARY KEY,                       -- Unique identifier for each audit entry
    table_name TEXT NOT NULL,                       -- Name of the table where the operation occurred
    record_id TEXT NOT NULL,                        -- ID of the affected row (cast to text for generality)
    operation TEXT NOT NULL,                        -- Operation type: INSERT, UPDATE, DELETE
    old_data JSONB,                                 -- Row state before the operation (null for INSERT)
    new_data JSONB,                                 -- Row state after the operation (null for DELETE)
    performed_by UUID,                              -- User ID performing the action (if available)
    performed_at TIMESTAMPTZ NOT NULL DEFAULT NOW() -- Timestamp when the operation was performed
);