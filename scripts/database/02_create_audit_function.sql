-- 02_create_audit_function.sql
-- ============================================================
-- Description: Defines the audit trigger function. Captures old/new row data
--              and writes it to audit_log. Supports INSERT, UPDATE, DELETE.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_write_audit()
RETURNS TRIGGER AS $$
DECLARE
    user_id UUID;  -- Will hold the UUID of the current user
BEGIN
    -- Try to capture the current user performing the operation (if available)
    BEGIN
        SELECT auth.uid() INTO user_id;
    EXCEPTION WHEN OTHERS THEN
        user_id := NULL;
    END;

    -- INSERT operation
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (
            table_name,
            record_id,
            operation,
            old_data,
            new_data,
            performed_by
        ) VALUES (
            TG_TABLE_NAME,
            NEW.id::TEXT,
            TG_OP,
            NULL,
            TO_JSONB(NEW),
            user_id
        );
        RETURN NEW;

    -- UPDATE operation
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (
            table_name,
            record_id,
            operation,
            old_data,
            new_data,
            performed_by
        ) VALUES (
            TG_TABLE_NAME,
            NEW.id::TEXT,
            TG_OP,
            TO_JSONB(OLD),
            TO_JSONB(NEW),
            user_id
        );
        RETURN NEW;

    -- DELETE operation
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (
            table_name,
            record_id,
            operation,
            old_data,
            new_data,
            performed_by
        ) VALUES (
            TG_TABLE_NAME,
            OLD.id::TEXT,
            TG_OP,
            TO_JSONB(OLD),
            NULL,
            user_id
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
