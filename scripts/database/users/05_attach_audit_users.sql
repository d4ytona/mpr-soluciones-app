-- 05_attach_audit_users.sql
-- ============================================================
-- Description: Attaches the generic audit trigger to the users table.
-- ============================================================

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trg_audit_users ON public.users;

-- Create trigger for INSERT, UPDATE, DELETE operations
CREATE TRIGGER trg_audit_users
AFTER INSERT OR UPDATE OR DELETE ON public.users
FOR EACH ROW
EXECUTE FUNCTION fn_write_audit();
