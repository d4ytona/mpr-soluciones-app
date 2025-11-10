-- 05_attach_audit_companies.sql
-- ============================================================
-- Description: Attaches the generic audit trigger to the companies table.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_companies ON companies;

CREATE TRIGGER trg_audit_companies
AFTER INSERT OR UPDATE OR DELETE ON companies
FOR EACH ROW
EXECUTE FUNCTION fn_write_audit();
