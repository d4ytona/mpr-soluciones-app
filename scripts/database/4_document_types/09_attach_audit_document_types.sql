-- 09_attach_audit_document_types.sql
-- ============================================================
-- Description: Attaches the generic audit trigger to document_types.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_document_types ON document_types;

CREATE TRIGGER trg_audit_document_types
AFTER INSERT OR UPDATE OR DELETE ON document_types
FOR EACH ROW
EXECUTE FUNCTION fn_write_audit();
